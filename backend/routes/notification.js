const express = require('express');
const router = express.Router();
const { protect, adminOnly } = require('../middleware/auth');
const {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  getPreferences,
  updatePreferences,
  sendTestNotification,
} = require('../controllers/notificationController');

// All routes require auth
router.use(protect);

// User notification routes
router.get('/', getNotifications);
router.get('/unread-count', getUnreadCount);
router.patch('/:id/read', markAsRead);
router.patch('/read-all', markAllAsRead);

// Preference routes
router.get('/preferences', getPreferences);
router.put('/preferences', updatePreferences);

// Admin-only routes
router.post('/test', adminOnly, sendTestNotification);

module.exports = router;
