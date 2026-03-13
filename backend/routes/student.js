const express = require('express');
const { getAssignedHouses } = require('../controllers/studentController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/houses/:studentId', protect, getAssignedHouses);

module.exports = router;
