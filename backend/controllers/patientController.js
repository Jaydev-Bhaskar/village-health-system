const PatientRecord = require('../models/PatientRecord');
const { validateRequired } = require('../middleware/validate');
const { detectRisk } = require('../services/mlService');
const NotificationService = require('../services/notificationService');

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
        bp: req.body.bloodPressure,
        blood_sugar: req.body.vitals?.bloodSugar,
        weight: req.body.weight,
        height: req.body.height
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

    // ── Notification triggers (fire-and-forget) ───────────────────────────
    try {
      // Detect high-risk conditions from risk result
      const highRiskConditions = [];
      if (riskResult) {
        if (riskResult.hypertension === 'high') highRiskConditions.push('Hypertension');
        if (riskResult.diabetes === 'high') highRiskConditions.push('Diabetes');
        if (riskResult.obesity === 'high') highRiskConditions.push('Obesity');
        if (riskResult.overallRisk === 'high' || riskResult.risk_level === 'high') {
          if (highRiskConditions.length === 0) highRiskConditions.push('General High Risk');
        }
      }

      // Send high-risk alert if conditions detected
      if (highRiskConditions.length > 0) {
        await NotificationService.sendHighRiskAlert(
          req.user._id,
          req.body.patientName.trim(),
          req.body.houseId,
          highRiskConditions
        );
      }

      // Send patient follow-up SMS if phone number provided
      if (req.body.patientPhone) {
        const followupDate = new Date();
        followupDate.setDate(followupDate.getDate() + 7);
        const dateStr = followupDate.toLocaleDateString('en-IN');

        await NotificationService.sendPatientFollowup(
          req.user._id,
          req.body.patientName.trim(),
          req.body.patientPhone,
          dateStr
        );
      }
    } catch (notifErr) {
      // Notifications are non-critical — log but don't fail the request
      console.error('Notification send error:', notifErr.message);
    }
    // ────────────────────────────────────────────────────────────────────────

    res.status(201).json({ message: 'Record saved successfully', record });
  } catch (err) {
    res.status(500).json({ message: 'Failed to save patient record' });
  }
};

module.exports = { createRecord };
