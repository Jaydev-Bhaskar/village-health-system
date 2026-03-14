const express = require('express');
const {
  getAdminDashboard,
  getAnalytics,
  uploadStudents,
  uploadHouses,
  runClustering,
} = require('../controllers/adminController');
const { protect, adminOnly } = require('../middleware/auth');

const router = express.Router();

router.use(protect, adminOnly);

router.get('/dashboard', getAdminDashboard);
router.get('/analytics', getAnalytics);
router.post('/upload-students', uploadStudents);
router.post('/upload-houses', uploadHouses);
router.post('/run-clustering', runClustering);

module.exports = router;
