import 'package:flutter/material.dart';
import '/models/medication.dart';
import '/models/reminder.dart';
import '/models/intakeHistory.dart';
import '/l10n/app_localizations.dart';
import 'medicine_schedule_item_widget.dart';

/// Reusable widget for displaying today's medication schedule
class TodayScheduleWidget extends StatelessWidget {
  final List<Medication> medications;
  final List<Reminder> reminders;
  final List<IntakeHistory> todayIntakes;
  final Function(IntakeHistory, bool) onIntakeStatusChanged;

  const TodayScheduleWidget({
    super.key,
    required this.medications,
    required this.reminders,
    required this.todayIntakes,
    required this.onIntakeStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF4DD0E1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.todaySchedule,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...todayIntakes.map((intake) {
            final medication = medications.firstWhere(
              (m) => m.id == intake.medicationId,
              orElse: () => medications[0],
            );
            final reminder = reminders.firstWhere(
              (r) => r.id == intake.reminderId,
              orElse: () => reminders[0],
            );
            return MedicineScheduleItemWidget(
              medication: medication,
              reminder: reminder,
              intake: intake,
              onCheckboxChanged: (value) =>
                  onIntakeStatusChanged(intake, value),
            );
          }),
        ],
      ),
    );
  }
}
