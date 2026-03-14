const mongoose = require('mongoose');

const notificationPreferenceSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },

    // SMS toggles
    smsPatientFollowup: { type: Boolean, default: true },
    smsVisitReminder: { type: Boolean, default: true },
    smsHighRiskAlert: { type: Boolean, default: true },

    // In-app toggles
    appDailySummary: { type: Boolean, default: true },
    appAssignmentUpdates: { type: Boolean, default: true },
    appSystemAlerts: { type: Boolean, default: true },

    // Reminder frequency: how many days before to send reminder
    reminderFrequency: {
      type: String,
      enum: ['same_day', '1_day_before', '2_days_before'],
      default: '1_day_before',
    },

    // Preferred notification time (24h format, e.g., "08:00")
    preferredTime: {
      type: String,
      default: '08:00',
    },

    // Quiet hours
    quietHoursStart: {
      type: String,
      default: '21:00',
    },
    quietHoursEnd: {
      type: String,
      default: '07:00',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('NotificationPreference', notificationPreferenceSchema);
