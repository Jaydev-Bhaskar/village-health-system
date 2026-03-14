const express = require('express');
const {
  getDashboard,
  getAssignedHouses,
  getVisitHistory,
} = require('../controllers/studentController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.use(protect);

router.get('/dashboard', getDashboard);
router.get('/houses', getAssignedHouses);
router.get('/visit-history', getVisitHistory);

module.exports = router;
