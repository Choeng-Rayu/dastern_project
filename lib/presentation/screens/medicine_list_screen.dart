import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Medicine List screen - Shows list of medications
class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF4DD0E1), // Light blue/cyan
      body: Center(
        child: Text(
          l10n.medicineList,
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
