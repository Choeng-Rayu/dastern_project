import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/l10n/app_localizations.dart';
import '../providers/medication_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/intake_history_provider.dart';
import '../../models/intakeHistory.dart';
import '../../models/medication.dart';

/// Today's Reminders Screen - Shows medication schedule for today
class TodayRemindersScreen extends StatefulWidget {
  const TodayRemindersScreen({super.key});

  @override
  State<TodayRemindersScreen> createState() => _TodayRemindersScreenState();
}

class _TodayRemindersScreenState extends State<TodayRemindersScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final reminderProvider =
        Provider.of<ReminderProvider>(context, listen: false);
    final historyProvider =
        Provider.of<IntakeHistoryProvider>(context, listen: false);

    // Generate today's intake histories if not already done
    await historyProvider.generateTodayIntakes(reminderProvider.reminders);

    // Update missed intakes
    await historyProvider.updateMissedIntakes();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyProvider = Provider.of<IntakeHistoryProvider>(context);
    final medicationProvider = Provider.of<MedicationProvider>(context);

    final todayHistories = historyProvider.getTodayHistories();
    final pendingIntakes =
        todayHistories.where((h) => h.status == IntakeStatus.pending).toList();
    final completedIntakes =
        todayHistories.where((h) => h.status == IntakeStatus.taken).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todayReminders),
        elevation: 0,
      ),
      body: todayHistories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRemindersToday,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _initializeData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Statistics Card
                  _buildStatisticsCard(
                    context,
                    l10n,
                    todayHistories.length,
                    completedIntakes.length,
                    pendingIntakes.length,
                  ),

                  const SizedBox(height: 24),

                  // Upcoming/Pending Section
                  if (pendingIntakes.isNotEmpty) ...[
                    Text(
                      l10n.upcomingReminders,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...pendingIntakes.map((history) {
                      final medication = medicationProvider
                          .getMedicationById(history.medicationId);
                      if (medication == null) return const SizedBox.shrink();

                      return _IntakeCard(
                        history: history,
                        medication: medication,
                        onMarkTaken: () => _markAsTaken(context, history.id),
                        onSkip: () => _markAsSkipped(context, history.id),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Completed Section
                  if (completedIntakes.isNotEmpty) ...[
                    Text(
                      l10n.completedReminders,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...completedIntakes.map((history) {
                      final medication = medicationProvider
                          .getMedicationById(history.medicationId);
                      if (medication == null) return const SizedBox.shrink();

                      return _IntakeCard(
                        history: history,
                        medication: medication,
                        isCompleted: true,
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsCard(
    BuildContext context,
    AppLocalizations l10n,
    int total,
    int completed,
    int pending,
  ) {
    final adherence = total > 0 ? (completed / total * 100).round() : 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  l10n.completed,
                  completed.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatItem(
                  l10n.pending,
                  pending.toString(),
                  Colors.orange,
                  Icons.schedule,
                ),
                _buildStatItem(
                  l10n.adherenceRate,
                  '$adherence%',
                  Colors.blue,
                  Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _markAsTaken(BuildContext context, String historyId) async {
    final historyProvider =
        Provider.of<IntakeHistoryProvider>(context, listen: false);
    await historyProvider.markAsTaken(historyId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Marked as taken'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markAsSkipped(BuildContext context, String historyId) async {
    final historyProvider =
        Provider.of<IntakeHistoryProvider>(context, listen: false);
    await historyProvider.markAsSkipped(historyId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skipped'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class _IntakeCard extends StatelessWidget {
  final IntakeHistory history;
  final Medication medication;
  final VoidCallback? onMarkTaken;
  final VoidCallback? onSkip;
  final bool isCompleted;

  const _IntakeCard({
    required this.history,
    required this.medication,
    this.onMarkTaken,
    this.onSkip,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat.jm();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted ? Colors.green[200]! : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (medication.color ?? const Color(0xFF4DD0E1))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    medication.icon ?? Icons.medication,
                    color: medication.color ?? const Color(0xFF4DD0E1),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication.dosage.amount} ${_getUnitString(l10n, medication.dosage.unit)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          l10n.taken,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${l10n.scheduledFor}: ${timeFormat.format(history.scheduledTime)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (isCompleted && history.takenAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.check, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.takenAt}: ${timeFormat.format(history.takenAt!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMarkTaken,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(l10n.markAsTaken),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onSkip,
                    icon: const Icon(Icons.close),
                    label: Text(l10n.skip),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getUnitString(AppLocalizations l10n, Unit unit) {
    switch (unit) {
      case Unit.tablet:
        return l10n.tablet;
      case Unit.ml:
        return l10n.ml;
      case Unit.mg:
        return l10n.mg;
      case Unit.other:
        return l10n.other;
    }
  }
}
