const mongoose = require('mongoose');

const houseSchema = new mongoose.Schema(
  {
    address: {
      type: String,
      required: [true, 'Address is required'],
      trim: true,
    },
    latitude: {
      type: Number,
      required: [true, 'Latitude is required'],
    },
    longitude: {
      type: Number,
      required: [true, 'Longitude is required'],
    },
    riskLevel: {
      type: String,
      enum: ['LOW', 'MODERATE', 'HIGH'],
      default: 'LOW',
    },
    assignedStudentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('House', houseSchema);
