// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dastern_project/app.dart';
import 'package:dastern_project/presentation/providers/settings_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize settings provider
    final settingsProvider = SettingsProvider();
    await settingsProvider.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: const DasternApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(DasternApp), findsOneWidget);
  });
}
