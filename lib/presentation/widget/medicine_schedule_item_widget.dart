import 'package:flutter/material.dart';
import '/models/medication.dart';
import '/models/reminder.dart';
import '/models/intakeHistory.dart';
import '/l10n/app_localizations.dart';

/// Reusable widget for displaying a single medicine schedule item
class MedicineScheduleItemWidget extends StatelessWidget {
  final Medication medication;
  final Reminder reminder;
  final IntakeHistory intake;
  final ValueChanged<bool> onCheckboxChanged;

  const MedicineScheduleItemWidget({
    super.key,
    required this.medication,
    required this.reminder,
    required this.intake,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = intake.status == IntakeStatus.taken;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  medication.color ?? Colors.blue,
                  (medication.color ?? Colors.blue).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medication,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${reminder.dosageAmount} ${l10n.dose}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isCompleted,
            onChanged: (value) => onCheckboxChanged(value ?? false),
            activeColor: const Color(0xFF4DD0E1),
          ),
        ],
      ),
    );
  }
}
