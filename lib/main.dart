import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings provider
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  // Initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const DasternApp(),
    ),
  );
}
