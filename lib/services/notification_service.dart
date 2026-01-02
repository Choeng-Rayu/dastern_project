import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../models/medication.dart';

/// Notification service for medication reminders
/// Uses in-app notifications and scheduled callbacks
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Callback for when a notification fires
  Function(String medicationId, String reminderId)? onNotificationReceived;

  // Timer for checking reminders
  Timer? _reminderCheckTimer;

  // List of pending reminders with their scheduled times
  final Map<String, Timer> _scheduledTimers = {};

  // Notification listeners
  final List<Function(NotificationData)> _listeners = [];

  /// Initialize the notification service
  Future<void> initialize() async {
    // Start periodic check for reminders
    _startReminderCheck();
    debugPrint('NotificationService initialized');
  }

  /// Start periodic reminder checking
  void _startReminderCheck() {
    _reminderCheckTimer?.cancel();
    _reminderCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkPendingReminders(),
    );
  }

  /// Check for pending reminders that need to fire
  void _checkPendingReminders() {
    // This will be called by providers to check and trigger notifications
    debugPrint('Checking pending reminders...');
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

    // Only schedule if the time is in the future
    if (scheduledTime.isAfter(now)) {
      final duration = scheduledTime.difference(now);

      // Cancel existing timer for this reminder
      _scheduledTimers[id]?.cancel();

      // Schedule new timer
      _scheduledTimers[id] = Timer(duration, () {
        _triggerNotification(
          NotificationData(
            id: id,
            title: 'Medication Reminder',
            body: 'Time to take $medicationName - $dosageInfo',
            medicationId: medicationId,
            reminderId: id,
            scheduledTime: scheduledTime,
          ),
        );
      });

      debugPrint(
          'Scheduled reminder for $medicationName at $scheduledTime (in ${duration.inMinutes} minutes)');
    }
  }

  /// Cancel a scheduled reminder
  Future<void> cancelReminder(String id) async {
    _scheduledTimers[id]?.cancel();
    _scheduledTimers.remove(id);
    debugPrint('Cancelled reminder: $id');
  }

  /// Cancel all reminders for a medication
  Future<void> cancelAllRemindersForMedication(String medicationId) async {
    final keysToRemove = <String>[];
    _scheduledTimers.forEach((key, timer) {
      if (key.contains(medicationId)) {
        timer.cancel();
        keysToRemove.add(key);
      }
    });
    for (var key in keysToRemove) {
      _scheduledTimers.remove(key);
    }
    debugPrint('Cancelled all reminders for medication: $medicationId');
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    for (var timer in _scheduledTimers.values) {
      timer.cancel();
    }
    _scheduledTimers.clear();
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

  /// Trigger a notification
  void _triggerNotification(NotificationData data) {
    debugPrint('🔔 NOTIFICATION: ${data.title} - ${data.body}');

    // Call the callback if set
    onNotificationReceived?.call(data.medicationId, data.reminderId);

    // Notify all listeners
    for (var listener in _listeners) {
      listener(data);
    }
  }

  /// Add a listener for notifications
  void addListener(Function(NotificationData) listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(Function(NotificationData) listener) {
    _listeners.remove(listener);
  }

  /// Show an immediate notification (for testing or manual triggers)
  void showNotification({
    required String title,
    required String body,
    String? medicationId,
    String? reminderId,
  }) {
    _triggerNotification(
      NotificationData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        medicationId: medicationId ?? '',
        reminderId: reminderId ?? '',
        scheduledTime: DateTime.now(),
      ),
    );
  }

  /// Dispose the service
  void dispose() {
    _reminderCheckTimer?.cancel();
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
