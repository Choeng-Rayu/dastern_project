// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:dastern_project/app.dart';
import 'package:dastern_project/services/settings_service.dart';
import 'package:dastern_project/services/auth_service.dart';
import 'package:dastern_project/services/medication_service.dart';
import 'package:dastern_project/services/reminder_service.dart';
import 'package:dastern_project/services/intake_history_service.dart';
import 'package:dastern_project/services/notification_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize services
    final settingsService = SettingsService();
    final authService = AuthService();
    final medicationService = MedicationService();
    final reminderService = ReminderService();
    final intakeHistoryService = IntakeHistoryService();
    final notificationService = NotificationService();

    await settingsService.initialize();
    await authService.initialize();
    await medicationService.initialize();
    await reminderService.initialize();
    await intakeHistoryService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      DasternApp(
        notificationService: notificationService,
        settingsService: settingsService,
        authService: authService,
        medicationService: medicationService,
        reminderService: reminderService,
        intakeHistoryService: intakeHistoryService,
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(DasternApp), findsOneWidget);
  });
}
