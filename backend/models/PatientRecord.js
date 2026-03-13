const mongoose = require('mongoose');

const patientRecordSchema = new mongoose.Schema(
  {
    houseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'House',
      required: [true, 'House ID is required'],
    },
    studentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Student ID is required'],
    },
    patientName: {
      type: String,
      required: [true, 'Patient name is required'],
      trim: true,
    },
    disease: {
      type: String,
      required: [true, 'Disease/symptom is required'],
      trim: true,
    },
    bloodPressure: {
      type: String,
      required: [true, 'Blood pressure is required'],
    },
    notes: {
      type: String,
      trim: true,
      default: '',
    },
    selfiePath: {
      type: String,
      default: null,
    },
    riskResult: {
      type: mongoose.Schema.Types.Mixed, // store ML response as-is
      default: null,
    },
    visitTimestamp: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('PatientRecord', patientRecordSchema);
