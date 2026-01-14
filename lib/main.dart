import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';

import 'app.dart';
import 'models/patient.dart';
import 'services/settings_service.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';
import 'services/reminder_service.dart';
import 'services/intake_history_service.dart';
import 'services/notification_service.dart';

/// Demo account credentials for easy testing
const String demoPhone = '012345678';
const String demoPassword = '123456';

/// Create demo account if it doesn't exist
Future<void> createDemoAccountIfNeeded(AuthService authService) async {
  // Check if demo account already exists by trying to login
  final loginSuccess = await authService.login(
    phone: demoPhone,
    password: demoPassword,
  );

  if (!loginSuccess) {
    // Demo account doesn't exist, create it
    debugPrint('📱 [Main] Creating demo account...');

    final demoPatient = Patient(
      tel: demoPhone,
      name: 'Demo User',
      dateOfBirth: DateTime(1990, 1, 1),
      address: 'Phnom Penh, Cambodia',
      bloodtype: 'O+',
      familyContact: '098765432',
      weight: 65.0,
    );

    await authService.register(
      patient: demoPatient,
      password: demoPassword,
    );

    // Logout so user can login manually
    await authService.logout();

    debugPrint(
        '📱 [Main] ✅ Demo account created: Phone=$demoPhone, Password=$demoPassword');
  } else {
    // Demo account exists, logout so user can login
    await authService.logout();
    debugPrint('📱 [Main] Demo account already exists');
  }
}

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.initialize();

  // Initialize auth service
  final authService = AuthService();
  await authService.initialize();

  // Create demo account if needed (for easy testing)
  if (!authService.isLoggedIn) {
    await createDemoAccountIfNeeded(authService);
  }

  // Initialize medication service
  final medicationService = MedicationService();
  await medicationService.initialize();

  // Initialize reminder service
  final reminderService = ReminderService();
  await reminderService.initialize();

  // Initialize intake history service
  final intakeHistoryService = IntakeHistoryService();
  await intakeHistoryService.initialize();

  // Schedule today's reminders
  if (authService.currentPatient != null) {
    debugPrint(
        '📱 [Main] Scheduling today\'s reminders for user: ${authService.currentPatient!.tel}');
    final todayReminders = reminderService.getTodayReminders();
    debugPrint('📱 [Main] Found ${todayReminders.length} reminders for today');
    await notificationService.scheduleRemindersForToday(
      reminders: todayReminders,
      medications: medicationService.medications,
    );
  } else {
    debugPrint('📱 [Main] No user logged in, skipping reminder scheduling');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Only enable in debug mode
      builder: (context) => DasternApp(
        notificationService: notificationService,
        settingsService: settingsService,
        authService: authService,
        medicationService: medicationService,
        reminderService: reminderService,
        intakeHistoryService: intakeHistoryService,
      ),
    ),
  );
}
