import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/medication_provider.dart';
import 'presentation/providers/reminder_provider.dart';
import 'presentation/providers/intake_history_provider.dart';
import 'services/notification_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize settings provider
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  // Initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.initialize();

  // Initialize medication provider
  final medicationProvider = MedicationProvider();
  await medicationProvider.initialize();

  // Initialize reminder provider
  final reminderProvider = ReminderProvider();
  await reminderProvider.initialize();

  // Initialize intake history provider
  final intakeHistoryProvider = IntakeHistoryProvider();
  await intakeHistoryProvider.initialize();

  // Schedule today's reminders
  if (authProvider.currentPatient != null) {
    debugPrint(
        '📱 [Main] Scheduling today\'s reminders for user: ${authProvider.currentPatient!.tel}');
    final todayReminders = reminderProvider.getTodayReminders();
    debugPrint('📱 [Main] Found ${todayReminders.length} reminders for today');
    await notificationService.scheduleRemindersForToday(
      reminders: todayReminders,
      medications: medicationProvider.medications,
    );
  } else {
    debugPrint('📱 [Main] No user logged in, skipping reminder scheduling');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: medicationProvider),
        ChangeNotifierProvider.value(value: reminderProvider),
        ChangeNotifierProvider.value(value: intakeHistoryProvider),
      ],
      child: const DasternApp(),
    ),
  );
}
