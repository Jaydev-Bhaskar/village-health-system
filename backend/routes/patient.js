const express = require('express');
const { createRecord } = require('../controllers/patientController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// selfie image is optional — if uploaded it will be in req.file
router.post('/record', protect, upload.single('selfie'), createRecord);

module.exports = router;
