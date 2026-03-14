const Notification = require('../models/Notification');
const NotificationPreference = require('../models/NotificationPreference');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Get user's notifications (paginated)
 * @route   GET /api/notifications
 * @access  Private
 */
exports.getNotifications = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const filter = { recipientId: req.user._id };

    // Optional filters
    if (req.query.channel) filter.channel = req.query.channel;
    if (req.query.type) filter.type = req.query.type;
    if (req.query.read !== undefined) filter.read = req.query.read === 'true';

    const [notifications, total] = await Promise.all([
      Notification.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Notification.countDocuments(filter),
    ]);

    res.status(200).json({
      success: true,
      data: notifications,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ message: 'Failed to fetch notifications' });
  }
};

/**
 * @desc    Get unread notification count
 * @route   GET /api/notifications/unread-count
 * @access  Private
 */
exports.getUnreadCount = async (req, res) => {
  try {
    const count = await NotificationService.getUnreadCount(req.user._id);
    res.status(200).json({ success: true, unreadCount: count });
  } catch (error) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({ message: 'Failed to fetch unread count' });
  }
};

/**
 * @desc    Mark notification as read
 * @route   PATCH /api/notifications/:id/read
 * @access  Private
 */
exports.markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, recipientId: req.user._id },
      { read: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.status(200).json({ success: true, data: notification });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ message: 'Failed to update notification' });
  }
};

/**
 * @desc    Mark all notifications as read
 * @route   PATCH /api/notifications/read-all
 * @access  Private
 */
exports.markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { recipientId: req.user._id, read: false },
      { read: true }
    );
    res.status(200).json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Error marking all as read:', error);
    res.status(500).json({ message: 'Failed to update notifications' });
  }
};

/**
 * @desc    Get notification preferences
 * @route   GET /api/notifications/preferences
 * @access  Private
 */
exports.getPreferences = async (req, res) => {
  try {
    let prefs = await NotificationPreference.findOne({ userId: req.user._id });

    // Create default preferences if none exist
    if (!prefs) {
      prefs = await NotificationPreference.create({ userId: req.user._id });
    }

    res.status(200).json({ success: true, data: prefs });
  } catch (error) {
    console.error('Error fetching preferences:', error);
    res.status(500).json({ message: 'Failed to fetch preferences' });
  }
};

/**
 * @desc    Update notification preferences
 * @route   PUT /api/notifications/preferences
 * @access  Private
 */
exports.updatePreferences = async (req, res) => {
  try {
    const allowedFields = [
      'smsPatientFollowup',
      'smsVisitReminder',
      'smsHighRiskAlert',
      'appDailySummary',
      'appAssignmentUpdates',
      'appSystemAlerts',
      'reminderFrequency',
      'preferredTime',
      'quietHoursStart',
      'quietHoursEnd',
    ];

    const updates = {};
    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    const prefs = await NotificationPreference.findOneAndUpdate(
      { userId: req.user._id },
      updates,
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    res.status(200).json({ success: true, data: prefs });
  } catch (error) {
    console.error('Error updating preferences:', error);
    res.status(500).json({ message: 'Failed to update preferences' });
  }
};

/**
 * @desc    Send test notification (admin only)
 * @route   POST /api/notifications/test
 * @access  Admin
 */
exports.sendTestNotification = async (req, res) => {
  try {
    const { recipientId, type, title, message, channel } = req.body;

    let notification;
    if (channel === 'sms') {
      notification = await NotificationService.sendSMS({
        recipientId,
        phoneNumber: req.body.phoneNumber,
        type: type || 'system_alert',
        title: title || 'Test Notification',
        message: message || 'This is a test notification from Village Health System.',
      });
    } else {
      notification = await NotificationService.sendInApp({
        recipientId,
        type: type || 'system_alert',
        title: title || 'Test Notification',
        message: message || 'This is a test notification from Village Health System.',
      });
    }

    res.status(201).json({ success: true, data: notification });
  } catch (error) {
    console.error('Error sending test notification:', error);
    res.status(500).json({ message: 'Failed to send test notification' });
  }
};
