const express = require('express');
const {
  uploadStudents,
  uploadHouses,
  runClustering,
} = require('../controllers/adminController');
const { protect, adminOnly } = require('../middleware/auth');

const router = express.Router();

router.use(protect, adminOnly); // all admin routes require auth + admin role

router.post('/upload-students', uploadStudents);
router.post('/upload-houses', uploadHouses);
router.post('/run-clustering', runClustering);

module.exports = router;
