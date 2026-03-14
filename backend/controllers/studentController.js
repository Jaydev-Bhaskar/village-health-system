const House = require('../models/House');
const PatientRecord = require('../models/PatientRecord');
const User = require('../models/User');

// GET /api/student/dashboard
const getDashboard = async (req, res) => {
  try {
    const studentId = req.user._id;

    const assignedHouses = await House.countDocuments({ assignedStudentId: studentId });

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const visitsToday = await PatientRecord.countDocuments({
      studentId,
      visitTimestamp: { $gte: today, $lt: tomorrow },
    });

    const totalVisits = await PatientRecord.countDocuments({ studentId });

    // Recent visits (last 5)
    const recentVisits = await PatientRecord.find({ studentId })
      .sort({ visitTimestamp: -1 })
      .limit(5)
      .populate('houseId', 'address riskLevel')
      .lean();

    const pendingVisits = assignedHouses - visitsToday;

    res.status(200).json({
      success: true,
      data: {
        assignedHouses,
        visitsToday,
        pendingVisits: pendingVisits > 0 ? pendingVisits : 0,
        totalVisits,
        studentName: req.user.name,
        recentVisits: recentVisits.map((v) => ({
          id: v._id,
          houseId: v.houseId?._id || v.houseId,
          houseAddress: v.houseId?.address || 'Unknown',
          riskLevel: v.houseId?.riskLevel || v.riskResult?.overallRisk || 'LOW',
          patientName: v.patientName,
          visitDate: v.visitTimestamp,
          disease: v.disease,
        })),
      },
    });
  } catch (err) {
    console.error('Dashboard error:', err.message);
    res.status(500).json({ message: 'Failed to fetch dashboard' });
  }
};

// GET /api/student/houses
const getAssignedHouses = async (req, res) => {
  try {
    const studentId = req.user._id;
    const houses = await House.find({ assignedStudentId: studentId }).lean();

    // Attach last visit info for each house
    const housesWithVisits = await Promise.all(
      houses.map(async (h) => {
        const lastVisit = await PatientRecord.findOne({ houseId: h._id, studentId })
          .sort({ visitTimestamp: -1 })
          .lean();
        return {
          ...h,
          lastVisit: lastVisit
            ? {
                date: lastVisit.visitTimestamp,
                patientName: lastVisit.patientName,
                risk: lastVisit.riskResult?.overallRisk || 'LOW',
              }
            : null,
        };
      })
    );

    res.status(200).json({ success: true, data: housesWithVisits });
  } catch (err) {
    console.error('Houses error:', err.message);
    res.status(500).json({ message: 'Failed to fetch assigned houses' });
  }
};

// GET /api/student/visit-history
const getVisitHistory = async (req, res) => {
  try {
    const studentId = req.user._id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const filter = { studentId };

    // Optional risk filter
    if (req.query.risk) {
      filter['riskResult.overallRisk'] = req.query.risk.toUpperCase();
    }

    // Optional date filter
    if (req.query.period === 'today') {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      filter.visitTimestamp = { $gte: today };
    } else if (req.query.period === 'week') {
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      filter.visitTimestamp = { $gte: weekAgo };
    } else if (req.query.period === 'month') {
      const monthAgo = new Date();
      monthAgo.setMonth(monthAgo.getMonth() - 1);
      filter.visitTimestamp = { $gte: monthAgo };
    }

    const [records, total] = await Promise.all([
      PatientRecord.find(filter)
        .sort({ visitTimestamp: -1 })
        .skip(skip)
        .limit(limit)
        .populate('houseId', 'address riskLevel')
        .lean(),
      PatientRecord.countDocuments(filter),
    ]);

    // Stats
    const totalRecords = await PatientRecord.countDocuments({ studentId });
    const monthAgo = new Date();
    monthAgo.setMonth(monthAgo.getMonth() - 1);
    const thisMonth = await PatientRecord.countDocuments({
      studentId,
      visitTimestamp: { $gte: monthAgo },
    });
    const highRisk = await PatientRecord.countDocuments({
      studentId,
      'riskResult.overallRisk': 'HIGH',
    });

    res.status(200).json({
      success: true,
      data: records.map((r) => ({
        id: r._id,
        houseId: r.houseId?._id || r.houseId,
        houseAddress: r.houseId?.address || 'Unknown',
        riskLevel: r.houseId?.riskLevel || r.riskResult?.overallRisk || 'LOW',
        patientName: r.patientName,
        disease: r.disease,
        visitDate: r.visitTimestamp,
        bloodPressure: r.bloodPressure,
      })),
      stats: {
        total: totalRecords,
        thisMonth,
        highRisk,
      },
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (err) {
    console.error('Visit history error:', err.message);
    res.status(500).json({ message: 'Failed to fetch visit history' });
  }
};

module.exports = { getDashboard, getAssignedHouses, getVisitHistory };
