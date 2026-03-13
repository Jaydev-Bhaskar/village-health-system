const express = require('express');
const { verifyVisit } = require('../controllers/visitController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.post('/verify', protect, verifyVisit);

module.exports = router;
