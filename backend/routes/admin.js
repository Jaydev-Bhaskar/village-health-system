const express = require('express');
const {
  getAdminDashboard,
  getAnalytics,
  uploadStudents,
  uploadHouses,
  runClustering,
  getAllStudents,
  resetStudentPassword,
} = require('../controllers/adminController');
const { protect, adminOnly } = require('../middleware/auth');

const router = express.Router();

router.use(protect, adminOnly);

router.get('/dashboard', getAdminDashboard);
router.get('/analytics', getAnalytics);
router.get('/students', getAllStudents);
router.post('/upload-students', uploadStudents);
router.post('/upload-houses', uploadHouses);
router.post('/run-clustering', runClustering);
router.post('/reset-password', resetStudentPassword);

module.exports = router;
