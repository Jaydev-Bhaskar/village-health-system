const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    // Who this notification is for
    recipientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Recipient is required'],
    },

    // Notification type
    type: {
      type: String,
      enum: [
        'visit_reminder',        // Remind student about pending visit
        'patient_followup',      // SMS to patient for follow-up
        'high_risk_alert',       // Urgent alert for critical health findings
        'assignment_update',     // New house assignments
        'daily_summary',         // Daily visit summary
        'system_alert',          // System-level notifications
      ],
      required: [true, 'Notification type is required'],
    },

    // Delivery channel
    channel: {
      type: String,
      enum: ['sms', 'in_app', 'both'],
      default: 'in_app',
    },

    // Notification content
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
    },
    message: {
      type: String,
      required: [true, 'Message is required'],
      trim: true,
    },

    // SMS-specific fields
    phoneNumber: {
      type: String,
      default: null,
    },
    smsStatus: {
      type: String,
      enum: ['pending', 'sent', 'delivered', 'failed', 'not_applicable'],
      default: 'not_applicable',
    },

    // In-app status
    read: {
      type: Boolean,
      default: false,
    },

    // Reference data (optional context)
    referenceId: {
      type: mongoose.Schema.Types.ObjectId,
      default: null,
    },
    referenceType: {
      type: String,
      enum: ['house', 'patient_record', 'visit', 'assignment', null],
      default: null,
    },

    // Scheduling
    scheduledFor: {
      type: Date,
      default: null,
    },
    sentAt: {
      type: Date,
      default: null,
    },

    // Priority
    priority: {
      type: String,
      enum: ['low', 'normal', 'high', 'critical'],
      default: 'normal',
    },
  },
  { timestamps: true }
);

// Index for quick lookups
notificationSchema.index({ recipientId: 1, read: 1, createdAt: -1 });
notificationSchema.index({ scheduledFor: 1, smsStatus: 1 });

module.exports = mongoose.model('Notification', notificationSchema);
