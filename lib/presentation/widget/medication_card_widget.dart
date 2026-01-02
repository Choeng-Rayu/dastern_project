import 'package:flutter/material.dart';
import '/models/medication.dart';
import '/models/intakeHistory.dart';
import '/l10n/app_localizations.dart';

/// Reusable widget for displaying a medication card
class MedicationCardWidget extends StatelessWidget {
  final Medication medication;
  final IntakeHistory intake;

  const MedicationCardWidget({
    super.key,
    required this.medication,
    required this.intake,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = intake.status == IntakeStatus.taken;

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            medication.color ?? Colors.blue,
            (medication.color ?? Colors.blue).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            medication.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Icon(
            Icons.medication,
            color: Colors.white,
            size: 24,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCompleted ? l10n.completed : l10n.pending,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
