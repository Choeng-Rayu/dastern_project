import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';

/// Medicine Form screen - CRUD operations for medicine
class MedicineFormScreen extends StatelessWidget {
  const MedicineFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF4DD0E1), // Light blue/cyan
      body: Center(
        child: Text(
          l10n.addMedicine,
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
