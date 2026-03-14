const Notification = require('../models/Notification');
const NotificationPreference = require('../models/NotificationPreference');

/**
 * Notification Service
 *
 * Handles creating, scheduling, and sending notifications
 * through SMS and in-app channels.
 */
class NotificationService {
  /**
   * Create and send an in-app notification
   */
  static async sendInApp({ recipientId, type, title, message, referenceId, referenceType, priority }) {
    const notification = await Notification.create({
      recipientId,
      type,
      channel: 'in_app',
      title,
      message,
      referenceId: referenceId || null,
      referenceType: referenceType || null,
      priority: priority || 'normal',
      sentAt: new Date(),
    });
    return notification;
  }

  /**
   * Create and send an SMS notification
   * NOTE: In production, integrate with Twilio, AWS SNS, or similar.
   * This implementation logs the SMS and marks it as sent.
   */
  static async sendSMS({ recipientId, phoneNumber, type, title, message, referenceId, referenceType, priority }) {
    // Check user preferences before sending
    const prefs = await NotificationPreference.findOne({ userId: recipientId });
    if (prefs) {
      const shouldSend = NotificationService._shouldSendSMS(prefs, type);
      if (!shouldSend) {
        console.log(`SMS suppressed for user ${recipientId} (type: ${type}) — disabled in preferences`);
        return null;
      }
    }

    // Create notification record
    const notification = await Notification.create({
      recipientId,
      type,
      channel: 'sms',
      title,
      message,
      phoneNumber,
      smsStatus: 'pending',
      referenceId: referenceId || null,
      referenceType: referenceType || null,
      priority: priority || 'normal',
    });

    // --- SMS Gateway Integration Point ---
    // Replace with actual SMS provider (Twilio, MSG91, etc.)
    try {
      console.log(`[SMS] To: ${phoneNumber} | Message: ${message}`);
      // await twilioClient.messages.create({
      //   body: message,
      //   to: phoneNumber,
      //   from: process.env.TWILIO_PHONE_NUMBER,
      // });

      notification.smsStatus = 'sent';
      notification.sentAt = new Date();
      await notification.save();
    } catch (error) {
      console.error(`[SMS FAILED] To: ${phoneNumber} | Error: ${error.message}`);
      notification.smsStatus = 'failed';
      await notification.save();
    }

    return notification;
  }

  /**
   * Send notification through both channels
   */
  static async sendBoth(params) {
    const [inApp, sms] = await Promise.all([
      NotificationService.sendInApp(params),
      params.phoneNumber ? NotificationService.sendSMS(params) : null,
    ]);
    return { inApp, sms };
  }

  /**
   * Send visit reminder to a student
   */
  static async sendVisitReminder(studentId, houseId, houseName, visitDate) {
    const message = `Reminder: You have a scheduled visit to ${houseName} on ${visitDate}. Please ensure you are prepared with necessary equipment.`;
    return NotificationService.sendInApp({
      recipientId: studentId,
      type: 'visit_reminder',
      title: 'Visit Reminder',
      message,
      referenceId: houseId,
      referenceType: 'house',
    });
  }

  /**
   * Send patient follow-up SMS
   */
  static async sendPatientFollowup(recipientId, patientName, phoneNumber, followupDate) {
    const message = `Dear ${patientName}, your health follow-up visit is scheduled on ${followupDate}. Please be available at home. — Village Health Team`;
    return NotificationService.sendSMS({
      recipientId,
      phoneNumber,
      type: 'patient_followup',
      title: 'Patient Follow-up',
      message,
    });
  }

  /**
   * Send high-risk alert after NCD screening
   */
  static async sendHighRiskAlert(studentId, patientName, houseId, conditions) {
    const conditionsList = conditions.join(', ');
    const message = `⚠ HIGH RISK ALERT: Patient ${patientName} has been screened with critical conditions: ${conditionsList}. Immediate follow-up recommended.`;
    return NotificationService.sendInApp({
      recipientId: studentId,
      type: 'high_risk_alert',
      title: 'High Risk Patient Alert',
      message,
      referenceId: houseId,
      referenceType: 'house',
      priority: 'critical',
    });
  }

  /**
   * Send assignment update notification
   */
  static async sendAssignmentUpdate(studentId, houseCount) {
    const message = `You have been assigned ${houseCount} new houses for field visits. Open the map to view your assignments.`;
    return NotificationService.sendInApp({
      recipientId: studentId,
      type: 'assignment_update',
      title: 'New Assignment',
      message,
      priority: 'high',
    });
  }

  /**
   * Get unread notification count for a user
   */
  static async getUnreadCount(userId) {
    return Notification.countDocuments({ recipientId: userId, read: false, channel: { $in: ['in_app', 'both'] } });
  }

  /**
   * Check if SMS should be sent based on user preferences
   */
  static _shouldSendSMS(prefs, type) {
    switch (type) {
      case 'patient_followup':
        return prefs.smsPatientFollowup;
      case 'visit_reminder':
        return prefs.smsVisitReminder;
      case 'high_risk_alert':
        return prefs.smsHighRiskAlert;
      default:
        return true;
    }
  }
}

module.exports = NotificationService;
