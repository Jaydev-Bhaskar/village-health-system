const User = require('../models/User');
const House = require('../models/House');
const HouseAssignment = require('../models/HouseAssignment');
const PatientRecord = require('../models/PatientRecord');
const { clusterHouses } = require('../services/mlService');

// GET /api/admin/dashboard
const getAdminDashboard = async (req, res) => {
  try {
    const [totalHouses, totalStudents, totalVisits, highRiskPatients] = await Promise.all([
      House.countDocuments({}),
      User.countDocuments({ role: 'student' }),
      PatientRecord.countDocuments({}),
      PatientRecord.countDocuments({ 'riskResult.overallRisk': 'HIGH' }),
    ]);

    res.status(200).json({
      success: true,
      data: { totalHouses, totalStudents, totalVisits, highRiskPatients },
    });
  } catch (err) {
    console.error('Admin dashboard error:', err.message);
    res.status(500).json({ message: 'Failed to fetch admin dashboard' });
  }
};

// GET /api/admin/analytics
const getAnalytics = async (req, res) => {
  try {
    // Parse date range
    let startDate = null;
    const period = req.query.period || 'month';
    const now = new Date();
    if (period === 'week') {
      startDate = new Date(now);
      startDate.setDate(now.getDate() - 7);
    } else if (period === 'month') {
      startDate = new Date(now);
      startDate.setMonth(now.getMonth() - 1);
    } else if (period === '3months') {
      startDate = new Date(now);
      startDate.setMonth(now.getMonth() - 3);
    }
    // 'all' => no date filter

    const dateFilter = startDate ? { visitTimestamp: { $gte: startDate } } : {};

    // Total visits
    const totalVisits = await PatientRecord.countDocuments(dateFilter);

    // Visits per day (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const dailyVisits = await PatientRecord.aggregate([
      { $match: { visitTimestamp: { $gte: thirtyDaysAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$visitTimestamp' } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // NCD distribution
    const allRecords = await PatientRecord.find(dateFilter).select('riskResult').lean();
    let hypertension = 0, diabetes = 0, obesity = 0, normal = 0;
    for (const r of allRecords) {
      if (!r.riskResult) { normal++; continue; }
      if (r.riskResult.hypertension === 'high') hypertension++;
      if (r.riskResult.diabetes === 'high') diabetes++;
      if (r.riskResult.obesity === 'high') obesity++;
      if (!r.riskResult.hypertension || (r.riskResult.hypertension !== 'high' &&
          r.riskResult.diabetes !== 'high' && r.riskResult.obesity !== 'high')) {
        normal++;
      }
    }

    // Risk distribution
    const riskCounts = await PatientRecord.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: '$riskResult.overallRisk',
          count: { $sum: 1 },
        },
      },
    ]);

    const riskDistribution = { normal: 0, moderate: 0, high: 0 };
    for (const r of riskCounts) {
      const key = (r._id || 'normal').toLowerCase();
      if (riskDistribution[key] !== undefined) {
        riskDistribution[key] = r.count;
      } else {
        riskDistribution.normal += r.count;
      }
    }
    const riskTotal = riskDistribution.normal + riskDistribution.moderate + riskDistribution.high || 1;

    // BMI categories
    const bmiRecords = await PatientRecord.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: '$riskResult.bmiCategory',
          count: { $sum: 1 },
        },
      },
    ]);
    const bmiDist = { underweight: 0, normal: 0, overweight: 0, obese: 0 };
    for (const b of bmiRecords) {
      const key = (b._id || 'normal').toLowerCase();
      if (bmiDist[key] !== undefined) bmiDist[key] = b.count;
    }

    res.status(200).json({
      success: true,
      data: {
        totalVisits,
        dailyVisits: dailyVisits.map((d) => ({ date: d._id, count: d.count })),
        ncdDistribution: { hypertension, diabetes, obesity, normal },
        riskDistribution: {
          normal: { count: riskDistribution.normal, percentage: Math.round((riskDistribution.normal / riskTotal) * 100) },
          moderate: { count: riskDistribution.moderate, percentage: Math.round((riskDistribution.moderate / riskTotal) * 100) },
          high: { count: riskDistribution.high, percentage: Math.round((riskDistribution.high / riskTotal) * 100) },
        },
        bmiDistribution: bmiDist,
      },
    });
  } catch (err) {
    console.error('Analytics error:', err.message);
    res.status(500).json({ message: 'Failed to fetch analytics' });
  }
};

// POST /api/admin/upload-students
const uploadStudents = async (req, res) => {
  try {
    const students = req.body.students;
    if (!Array.isArray(students) || students.length === 0) {
      return res.status(400).json({ message: 'Provide a non-empty students array' });
    }

    const results = [];
    for (const s of students) {
      const exists = await User.findOne({ email: s.email });
      if (!exists) {
        const user = await User.create({
          name: s.name,
          email: s.email,
          password: s.password || 'VillageHealth@123',
          role: 'student',
        });
        results.push({ id: user._id, email: user.email, created: true });
      } else {
        results.push({ id: exists._id, email: exists.email, created: false });
      }
    }

    res.status(201).json({ message: 'Students processed', results });
  } catch (err) {
    res.status(500).json({ message: 'Failed to upload students' });
  }
};

// POST /api/admin/upload-houses
const uploadHouses = async (req, res) => {
  try {
    const houses = req.body.houses;
    if (!Array.isArray(houses) || houses.length === 0) {
      return res.status(400).json({ message: 'Provide a non-empty houses array' });
    }

    const created = await House.insertMany(houses, { ordered: false });
    res.status(201).json({ message: 'Houses uploaded', count: created.length });
  } catch (err) {
    res.status(500).json({ message: 'Failed to upload houses' });
  }
};

// POST /api/admin/run-clustering
const runClustering = async (req, res) => {
  try {
    const houses = await House.find({});
    const students = await User.find({ role: 'student' });

    if (houses.length === 0) {
      return res.status(400).json({ message: 'No houses found to cluster' });
    }

    const clusterResult = await clusterHouses(
      houses.map((h) => ({
        id: h._id,
        latitude: h.latitude,
        longitude: h.longitude,
        riskLevel: h.riskLevel,
      }))
    );

    const assignments = clusterResult.assignments || [];
    await HouseAssignment.deleteMany({});

    const studentIds = students.map((s) => s._id);
    const saved = [];

    for (const a of assignments) {
      const studentIndex = a.clusterId % studentIds.length;
      const studentId = studentIds[studentIndex];

      await House.findByIdAndUpdate(a.houseId, { assignedStudentId: studentId });

      const doc = await HouseAssignment.create({
        houseId: a.houseId,
        studentId,
        clusterId: a.clusterId,
      });
      saved.push(doc);
    }

    res.status(200).json({
      message: 'Clustering complete',
      assignments: saved.length,
      clusterResult,
    });
  } catch (err) {
    console.error('Clustering error:', err.message);
    res.status(500).json({ message: 'Clustering failed' });
  }
};

module.exports = { getAdminDashboard, getAnalytics, uploadStudents, uploadHouses, runClustering };
