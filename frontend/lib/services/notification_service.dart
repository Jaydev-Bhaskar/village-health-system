import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notification service for in-app push notifications.
/// Handles both Android and iOS notification channels.
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap — navigate to relevant screen
    // The payload can contain route information
    final payload = response.payload;
    if (payload != null) {
      // TODO: Navigate based on payload
    }
  }

  /// Show a local notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'village_health_channel',
      'Village Health Alerts',
      channelDescription: 'Notifications for village health monitoring',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id: id, title: title, body: body, notificationDetails: details, payload: payload);
  }

  /// Show a visit reminder notification
  static Future<void> showVisitReminder(String houseName, String time) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📋 Visit Reminder',
      body: 'You have a scheduled visit to $houseName at $time',
      payload: 'visit_reminder',
    );
  }

  /// Show a high-risk alert notification
  static Future<void> showHighRiskAlert(String patientName, List<String> conditions) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '⚠️ High Risk Alert',
      body: 'Patient $patientName: ${conditions.join(", ")}',
      payload: 'high_risk_alert',
    );
  }

  /// Show assignment update notification
  static Future<void> showAssignmentUpdate(int houseCount) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🏠 New Assignment',
      body: 'You have been assigned $houseCount new houses',
      payload: 'assignment_update',
    );
  }
}
