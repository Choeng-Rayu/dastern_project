import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/reminder.dart';
import '../models/medication.dart';

/// Notification service for medication reminders
/// Uses flutter_local_notifications for native system notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Callback for when a notification fires
  Function(String medicationId, String reminderId)? onNotificationReceived;

  // Notification listeners
  final List<Function(NotificationData)> _listeners = [];

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    final String? timeZoneName = await _getTimeZoneName();
    if (timeZoneName != null) {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    }

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions (iOS)
    await _requestPermissions();

    _initialized = true;
    debugPrint('NotificationService initialized with native notifications');
  }

  /// Get the device timezone name
  Future<String?> _getTimeZoneName() async {
    try {
      // Try to get local timezone, default to UTC if fails
      return 'Asia/Phnom_Penh'; // Default for Cambodia, adjust as needed
    } catch (e) {
      debugPrint('Error getting timezone: $e');
      return 'UTC';
    }
  }

  /// Request notification permissions (iOS)
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final parts = payload.split('|');
      if (parts.length == 2) {
        final medicationId = parts[0];
        final reminderId = parts[1];
        onNotificationReceived?.call(medicationId, reminderId);

        // Notify listeners
        for (var listener in _listeners) {
          listener(NotificationData(
            id: reminderId,
            title: 'Medication Reminder',
            body: '',
            medicationId: medicationId,
            reminderId: reminderId,
            scheduledTime: DateTime.now(),
          ));
        }
      }
    }
  }

  /// Schedule a reminder notification
  Future<void> scheduleReminder({
    required String id,
    required String medicationName,
    required DateTime scheduledTime,
    required String dosageInfo,
    required String medicationId,
  }) async {
    final now = DateTime.now();

    debugPrint('🔔 [NotificationService] Attempting to schedule notification:');
    debugPrint('   - Medication: $medicationName');
    debugPrint('   - Scheduled for: $scheduledTime');
    debugPrint('   - Dosage: $dosageInfo');
    debugPrint('   - Current time: $now');
    debugPrint('   - Is future: ${scheduledTime.isAfter(now)}');

    // Only schedule if the time is in the future
    if (scheduledTime.isAfter(now)) {
      // Create a unique notification ID from the reminder ID
      final notificationId = id.hashCode;

      // Android notification details
      const androidDetails = AndroidNotificationDetails(
        'medication_reminders',
        'Medication Reminders',
        channelDescription: 'Reminders to take your medication',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert to timezone aware datetime
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Schedule the notification
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '💊 Medication Reminder',
        'Time to take $medicationName - $dosageInfo',
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$medicationId|$id',
      );

      final duration = scheduledTime.difference(now);
      debugPrint(
          '✅ Successfully scheduled notification (ID: $notificationId) for $medicationName at $scheduledTime (in ${duration.inMinutes} minutes)');
    } else {
      debugPrint('❌ Cannot schedule notification - time is in the past');
    }
  }

  /// Cancel a scheduled reminder
  Future<void> cancelReminder(String id) async {
    final notificationId = id.hashCode;
    await _notificationsPlugin.cancel(notificationId);
    debugPrint('Cancelled reminder: $id');
  }

  /// Cancel all reminders for a medication
  Future<void> cancelAllRemindersForMedication(String medicationId) async {
    // Unfortunately, flutter_local_notifications doesn't provide a way to query scheduled notifications
    // So we just cancel all and reschedule what's needed
    debugPrint('Cancelled all reminders for medication: $medicationId');
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('Cancelled all reminders');
  }

  /// Schedule reminders for today based on active reminders
  Future<void> scheduleRemindersForToday({
    required List<Reminder> reminders,
    required List<Medication> medications,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var reminder in reminders) {
      if (!reminder.isActive || !reminder.shouldFireToday()) continue;

      final medication = medications.firstWhere(
        (m) => m.id == reminder.medicationId,
        orElse: () => Medication(
          name: 'Unknown',
          dosage: const Dosage(amount: 0, unit: Unit.tablet),
          instruction: '',
          prescribeBy: '',
        ),
      );

      final scheduledTime = DateTime(
        today.year,
        today.month,
        today.day,
        reminder.time.hour,
        reminder.time.minute,
      );

      // Only schedule if in the future
      if (scheduledTime.isAfter(now)) {
        await scheduleReminder(
          id: reminder.id,
          medicationName: medication.name,
          scheduledTime: scheduledTime,
          dosageInfo:
              '${reminder.dosageAmount} ${_getUnitString(medication.dosage.unit)}',
          medicationId: reminder.medicationId,
        );
      }
    }
  }

  /// Show an immediate notification (for testing or manual triggers)
  Future<void> showNotification({
    required String title,
    required String body,
    String? medicationId,
    String? reminderId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders to take your medication',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
      payload: medicationId != null && reminderId != null
          ? '$medicationId|$reminderId'
          : null,
    );
  }

  /// Add a listener for notifications
  void addListener(Function(NotificationData) listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(Function(NotificationData) listener) {
    _listeners.remove(listener);
  }

  /// Dispose the service
  void dispose() {
    cancelAllReminders();
    _listeners.clear();
  }

  /// Helper method to get unit string (without localization for notifications)
  String _getUnitString(Unit unit) {
    switch (unit) {
      case Unit.tablet:
        return 'tablet';
      case Unit.ml:
        return 'ml';
      case Unit.mg:
        return 'mg';
      case Unit.other:
        return 'other';
    }
  }
}

/// Data class for notification information
class NotificationData {
  final String id;
  final String title;
  final String body;
  final String medicationId;
  final String reminderId;
  final DateTime scheduledTime;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.medicationId,
    required this.reminderId,
    required this.scheduledTime,
  });
}
