const House = require('../models/House');

// GET /api/student/houses/:studentId
const getAssignedHouses = async (req, res) => {
  try {
    const { studentId } = req.params;

    // Students can only access their own houses
    if (req.user._id.toString() !== studentId && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const houses = await House.find({ assignedStudentId: studentId });
    res.status(200).json(houses);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch assigned houses' });
  }
};

module.exports = { getAssignedHouses };
