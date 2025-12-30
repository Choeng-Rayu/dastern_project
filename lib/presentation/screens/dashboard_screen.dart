import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';

/// Dashboard screen - Main hub of the application
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF4DD0E1), // Light blue/cyan
      body: Center(
        child: Text(
          l10n.dashboard,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
