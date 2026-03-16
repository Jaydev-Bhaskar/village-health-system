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

    // House locations for map
    const houses = await House.find({}).select('address latitude longitude riskLevel').lean();

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
        houses: houses.map((h) => ({
          id: h._id,
          address: h.address,
          latitude: h.latitude,
          longitude: h.longitude,
          riskLevel: h.riskLevel || 'LOW',
        })),
      },
    });
  } catch (err) {
    console.error('Analytics error:', err.message);
    res.status(500).json({ message: 'Failed to fetch analytics' });
  }
};

// POST /api/admin/upload-students
// If studentId exists => skip, if not => create with password = studentId
const uploadStudents = async (req, res) => {
  try {
    const students = req.body.students;
    if (!Array.isArray(students) || students.length === 0) {
      return res.status(400).json({ message: 'Provide a non-empty students array' });
    }

    const results = [];
    for (const s of students) {
      try {
        // Check by studentId first
        if (s.studentId) {
          const existsByStudentId = await User.findOne({ studentId: s.studentId });
          if (existsByStudentId) {
            results.push({ studentId: s.studentId, name: existsByStudentId.name, created: false, reason: 'Student ID already exists' });
            continue;
          }
        }

        // Check by email if provided and non-empty
        if (s.email && s.email.trim()) {
          const existsByEmail = await User.findOne({ email: s.email.toLowerCase().trim() });
          if (existsByEmail) {
            results.push({ studentId: s.studentId, email: s.email, name: existsByEmail.name, created: false, reason: 'Email already exists' });
            continue;
          }
        }

        // Create new student - password defaults to studentId
        const password = s.password || s.studentId || 'VillageHealth@123';
        const userData = {
          name: s.name || `Student ${s.studentId}`,
          password: password,
          role: 'student',
        };

        // studentId is required for this flow
        if (s.studentId) {
          userData.studentId = s.studentId;
        }

        // Email is optional - only set if non-empty
        if (s.email && s.email.trim()) {
          userData.email = s.email.toLowerCase().trim();
        }

        const user = await User.create(userData);
        results.push({
          id: user._id,
          studentId: user.studentId,
          name: user.name,
          password: password,
          created: true,
        });
      } catch (innerErr) {
        // Handle duplicate key error for individual student
        if (innerErr.code === 11000) {
          const field = Object.keys(innerErr.keyPattern || {})[0] || 'unknown';
          results.push({
            studentId: s.studentId,
            created: false,
            reason: `Duplicate ${field}: already exists in database`,
          });
        } else {
          results.push({
            studentId: s.studentId,
            created: false,
            reason: innerErr.message || 'Creation failed',
          });
        }
      }
    }

    const created = results.filter(r => r.created).length;
    const skipped = results.filter(r => !r.created).length;

    res.status(201).json({
      message: `Students processed: ${created} created, ${skipped} skipped`,
      created,
      skipped,
      results,
    });
  } catch (err) {
    console.error('Upload students error:', err.message);
    res.status(500).json({ message: 'Failed to upload students: ' + err.message });
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
    console.error('Upload houses error:', err.message);
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
    if (students.length === 0) {
      return res.status(400).json({ message: 'No students found for assignment' });
    }

    // ML service expects: { students: int, houses: [{ id, lat, lng }] }
    const mlHouses = houses.map((h) => ({
      id: h._id.toString(),
      lat: h.latitude,
      lng: h.longitude,
    }));

    const clusterResult = await clusterHouses(students.length, mlHouses);

    // ML returns: { clusters: { "0": ["houseId1", ...], "1": [...] } }
    const clusters = clusterResult.clusters || {};
    await HouseAssignment.deleteMany({});

    const studentIds = students.map((s) => s._id);
    const saved = [];

    // Assign each cluster's houses to a student
    const clusterKeys = Object.keys(clusters);
    for (let i = 0; i < clusterKeys.length; i++) {
      const clusterId = parseInt(clusterKeys[i], 10);
      const houseIds = clusters[clusterKeys[i]] || [];
      const studentId = studentIds[i % studentIds.length];

      for (const houseId of houseIds) {
        await House.findByIdAndUpdate(houseId, { assignedStudentId: studentId });

        const doc = await HouseAssignment.create({
          houseId,
          studentId,
          clusterId,
        });
        saved.push(doc);
      }
    }

    res.status(200).json({
      message: 'Clustering complete',
      studentsAssigned: students.length,
      housesAssigned: saved.length,
      totalClusters: clusterKeys.length,
      assignments: saved.length,
      clusterResult,
    });
  } catch (err) {
    console.error('Clustering error:', err.message);
    res.status(500).json({ message: 'Clustering failed: ' + err.message });
  }
};

// GET /api/admin/students - Get all students with their passwords
const getAllStudents = async (req, res) => {
  try {
    const students = await User.find({ role: 'student' })
      .select('+plainPassword')
      .sort({ createdAt: -1 })
      .lean();

    const studentData = students.map(s => ({
      id: s._id,
      name: s.name,
      studentId: s.studentId || 'N/A',
      email: s.email || 'N/A',
      password: s.plainPassword || s.studentId || 'N/A',
      createdAt: s.createdAt,
    }));

    res.status(200).json({
      success: true,
      count: studentData.length,
      data: studentData,
    });
  } catch (err) {
    console.error('Get students error:', err.message);
    res.status(500).json({ message: 'Failed to fetch students' });
  }
};

// POST /api/admin/reset-password - Admin resets a student's password
const resetStudentPassword = async (req, res) => {
  try {
    const { userId, newPassword } = req.body;
    if (!userId || !newPassword) {
      return res.status(400).json({ message: 'Please provide userId and newPassword' });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    user.password = newPassword;
    await user.save();

    res.status(200).json({ message: 'Password reset successfully' });
  } catch (err) {
    console.error('Reset password error:', err.message);
    res.status(500).json({ message: 'Failed to reset password' });
  }
};

module.exports = { 
  getAdminDashboard, 
  getAnalytics, 
  uploadStudents, 
  uploadHouses, 
  runClustering, 
  getAllStudents,
  resetStudentPassword,
};
