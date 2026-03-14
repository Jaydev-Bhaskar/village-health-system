const express = require('express');
const { createRecord } = require('../controllers/patientController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

router.use(protect);

// selfie image is optional — if uploaded it will be in req.file
router.post('/record', upload.single('selfie'), createRecord);

// GET /api/patient/records — uses student controller's visit history
// This is handled via /api/student/visit-history endpoint

module.exports = router;
