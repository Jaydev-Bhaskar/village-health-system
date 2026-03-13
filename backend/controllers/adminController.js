const User = require('../models/User');
const House = require('../models/House');
const HouseAssignment = require('../models/HouseAssignment');
const { clusterHouses } = require('../services/mlService');

// POST /api/admin/upload-students
const uploadStudents = async (req, res) => {
  try {
    const students = req.body.students; // expect array
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
          password: s.password || 'VillageHealth@123', // default password
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
    // Fetch all houses and students
    const houses = await House.find({});
    const students = await User.find({ role: 'student' });

    if (houses.length === 0) {
      return res.status(400).json({ message: 'No houses found to cluster' });
    }

    // Call ML clustering service
    const clusterResult = await clusterHouses(
      houses.map((h) => ({
        id: h._id,
        latitude: h.latitude,
        longitude: h.longitude,
        riskLevel: h.riskLevel,
      }))
    );

    // Store assignments from ML result
    const assignments = clusterResult.assignments || [];
    await HouseAssignment.deleteMany({}); // clear old assignments

    const studentIds = students.map((s) => s._id);
    const saved = [];

    for (const a of assignments) {
      const studentIndex = a.clusterId % studentIds.length;
      const studentId = studentIds[studentIndex];

      // Update house with assigned student
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

module.exports = { uploadStudents, uploadHouses, runClustering };
