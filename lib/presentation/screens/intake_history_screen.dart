import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/medication_service.dart';
import '../../services/intake_history_service.dart';
import '../../models/intakeHistory.dart';
import '../../models/medication.dart';
import '../theme/theme.dart';
import '../layout/app_layout.dart';

/// Intake History Screen - Shows medication intake history with statistics
class IntakeHistoryScreen extends StatefulWidget {
  final MedicationService medicationService;
  final IntakeHistoryService intakeHistoryService;

  const IntakeHistoryScreen({
    super.key,
    required this.medicationService,
    required this.intakeHistoryService,
  });

  @override
  State<IntakeHistoryScreen> createState() => _IntakeHistoryScreenState();
}

class _IntakeHistoryScreenState extends State<IntakeHistoryScreen> {
  String _selectedFilter = 'all'; // all, week, month

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final startDate = _getStartDate(now);
    final histories = _getFilteredHistories(startDate, now);
    final stats = widget.intakeHistoryService.getStatistics(startDate, now);
    final adherenceRate =
        widget.intakeHistoryService.getAdherenceRate(startDate, now);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.intakeHistory),
        backgroundColor: isDarkMode
            ? theme.appBarTheme.backgroundColor
            : AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            color: isDarkMode ? theme.cardTheme.color : Colors.white,
            child: Row(
              children: [
                _buildFilterChip(l10n.all, 'all', l10n, isDarkMode),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.thisWeek, 'week', l10n, isDarkMode),
                const SizedBox(width: 8),
                _buildFilterChip(l10n.thisMonth, 'month', l10n, isDarkMode),
              ],
            ),
          ),

          // Statistics Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ThemedCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        l10n.taken,
                        '${stats['taken']}',
                        AppTheme.takenColor,
                        Icons.check_circle,
                        isDarkMode,
                      ),
                      _buildStatColumn(
                        l10n.missed,
                        '${stats['missed']}',
                        AppTheme.missedColor,
                        Icons.cancel,
                        isDarkMode,
                      ),
                      _buildStatColumn(
                        l10n.skipped,
                        '${stats['skipped']}',
                        AppTheme.skippedColor,
                        Icons.remove_circle_outline,
                        isDarkMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.adherenceRate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${adherenceRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getAdherenceColor(adherenceRate),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: adherenceRate / 100,
                        backgroundColor:
                            isDarkMode ? Colors.grey[700] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.getAdherenceColor(adherenceRate),
                        ),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // History List
          Expanded(
            child: histories.isEmpty
                ? EmptyState(
                    icon: Icons.history,
                    message: l10n.noHistoryYet,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: histories.length,
                    itemBuilder: (context, index) {
                      final history = histories[index];
                      final medication = widget.medicationService
                          .getMedicationById(history.medicationId);

                      if (medication == null) {
                        return const SizedBox.shrink();
                      }

                      return _HistoryCard(
                        history: history,
                        medication: medication,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String value, AppLocalizations l10n, bool isDarkMode) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppTheme.primaryColor,
      backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[200],
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDarkMode ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatColumn(
      String label, String value, Color color, IconData icon, bool isDarkMode) {
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
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  DateTime _getStartDate(DateTime now) {
    switch (_selectedFilter) {
      case 'week':
        return now.subtract(const Duration(days: 7));
      case 'month':
        return DateTime(now.year, now.month - 1, now.day);
      default:
        return DateTime(2000); // All time
    }
  }

  List<IntakeHistory> _getFilteredHistories(DateTime start, DateTime end) {
    return widget.intakeHistoryService.histories
        .where((h) =>
            h.scheduledTime.isAfter(start) && h.scheduledTime.isBefore(end))
        .toList()
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
  }
}

class _HistoryCard extends StatelessWidget {
  final IntakeHistory history;
  final Medication medication;
  final bool isDarkMode;

  const _HistoryCard({
    required this.history,
    required this.medication,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat.Hm();

    // Check if intake was delayed (taken more than 30 min after scheduled)
    final isDelayed = history.status == IntakeStatus.taken &&
        history.takenAt != null &&
        history.takenAt!.difference(history.scheduledTime).inMinutes > 30;

    return ThemedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  (medication.color ?? AppTheme.primaryColor).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              medication.icon ?? Icons.medication,
              color: medication.color ?? AppTheme.primaryColor,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(history.scheduledTime),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 14,
                        color: isDarkMode ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.scheduledFor} ${timeFormat.format(history.scheduledTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (history.status == IntakeStatus.taken &&
                    history.takenAt != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        isDelayed ? Icons.watch_later : Icons.check,
                        size: 14,
                        color: isDelayed
                            ? AppTheme.delayedColor
                            : AppTheme.takenColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.takenAt} ${timeFormat.format(history.takenAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDelayed
                              ? AppTheme.delayedColor
                              : AppTheme.takenColor,
                          fontWeight:
                              isDelayed ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isDelayed) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${l10n.delayed})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.delayedColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          StatusBadge(
            status: isDelayed ? 'delayed' : history.status.name,
            isSmall: true,
          ),
        ],
      ),
    );
  }
}
