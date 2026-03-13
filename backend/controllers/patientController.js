const PatientRecord = require('../models/PatientRecord');
const { validateRequired } = require('../middleware/validate');
const { detectRisk } = require('../services/mlService');

// POST /api/patient/record
const createRecord = async (req, res) => {
  try {
    const reqError = validateRequired(
      ['houseId', 'patientName', 'disease', 'bloodPressure'],
      req.body
    );
    if (reqError) return res.status(400).json({ message: reqError });

    // Call ML service for risk detection
    let riskResult = null;
    try {
      riskResult = await detectRisk({
        patientName: req.body.patientName,
        disease: req.body.disease,
        bloodPressure: req.body.bloodPressure,
        notes: req.body.notes || '',
      });
    } catch (mlErr) {
      // Degrade gracefully: save record without ML result
      console.error('ML service error:', mlErr.message);
    }

    const record = await PatientRecord.create({
      houseId: req.body.houseId,
      studentId: req.user._id,
      patientName: req.body.patientName.trim(),
      disease: req.body.disease.trim(),
      bloodPressure: req.body.bloodPressure.trim(),
      notes: req.body.notes ? req.body.notes.trim() : '',
      selfiePath: req.file ? req.file.path : null,
      riskResult,
    });

    res.status(201).json({ message: 'Record saved successfully', record });
  } catch (err) {
    res.status(500).json({ message: 'Failed to save patient record' });
  }
};

module.exports = { createRecord };
