import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/intakeHistory.dart';
import '../../models/medication.dart';
import '../../services/auth_service.dart';
import '../../services/medication_service.dart';
import '../../services/reminder_service.dart';
import '../../services/intake_history_service.dart';
import '../layout/app_layout.dart';
import '../theme/theme.dart';
import '../widget/gradient_background.dart';
import './medicine_form_screen.dart';

/// Dashboard screen - Main hub with real-time medication data
class DashboardScreen extends StatefulWidget {
  final AuthService authService;
  final MedicationService medicationService;
  final ReminderService reminderService;
  final IntakeHistoryService intakeHistoryService;
  final VoidCallback? onViewAllMedications;

  const DashboardScreen({
    super.key,
    required this.authService,
    required this.medicationService,
    required this.reminderService,
    required this.intakeHistoryService,
    this.onViewAllMedications,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Generate today's intakes on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateTodayIntakes();
    });
  }

  Future<void> _generateTodayIntakes() async {
    await widget.intakeHistoryService
        .generateTodayIntakes(widget.reminderService.reminders);
    if (mounted) {
      setState(() {}); // Refresh UI after generating intakes
    }
  }

  /// Refresh all dashboard data
  Future<void> _refreshDashboard() async {
    // Reload all data from storage
    await Future.wait([
      widget.medicationService.initialize(),
      widget.reminderService.initialize(),
      widget.intakeHistoryService.initialize(),
    ]);

    // Generate today's intakes with fresh reminder data
    await widget.intakeHistoryService
        .generateTodayIntakes(widget.reminderService.reminders);

    // Update UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        isDarkMode: isDarkMode,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            color: const Color(0xFF4DD0E1),
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(l10n),
                    const SizedBox(height: 20),
                    _buildGreeting(l10n, isDarkMode),
                    const SizedBox(height: 16),
                    _buildQuickStats(l10n, isDarkMode),
                    const SizedBox(height: 16),
                    _buildMedicationCards(l10n, isDarkMode),
                    const SizedBox(height: 16),
                    _buildQuickActions(l10n, isDarkMode),
                    const SizedBox(height: 16),
                    _buildTodaySchedule(l10n, isDarkMode),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const CircleAvatar(
            backgroundColor: Color(0xFF4DD0E1),
            radius: 24,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.patient,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                widget.authService.currentPatient?.name ?? 'Guest',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pushNamed(context, '/today-reminders'),
        ),
      ],
    );
  }

  Widget _buildGreeting(AppLocalizations l10n, bool isDarkMode) {
    final now = DateTime.now();
    final greeting = _getGreeting(now, l10n);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.hello} ${widget.authService.currentPatient?.name ?? 'Guest'}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat.yMMMMd(Localizations.localeOf(context).languageCode)
                .format(now),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(DateTime now, AppLocalizations l10n) {
    final hour = now.hour;
    if (hour < 12) {
      return l10n.morning;
    } else if (hour < 17) {
      return l10n.afternoon;
    } else if (hour < 21) {
      return l10n.evening;
    } else {
      return l10n.night;
    }
  }

  Widget _buildQuickStats(AppLocalizations l10n, bool isDarkMode) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final stats = widget.intakeHistoryService.getStatistics(today, tomorrow);
    final taken = stats['taken'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final missed = stats['missed'] ?? 0;

    return Row(
      children: [
        _buildStatCard(
          l10n.taken,
          taken.toString(),
          Icons.check_circle,
          AppTheme.takenColor,
          isDarkMode,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          l10n.pending,
          pending.toString(),
          Icons.schedule,
          AppTheme.pendingColor,
          isDarkMode,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          l10n.missed,
          missed.toString(),
          Icons.cancel,
          AppTheme.missedColor,
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCards(AppLocalizations l10n, bool isDarkMode) {
    final medications = widget.medicationService.medications;

    if (medications.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 48,
              color: isDarkMode ? Colors.white54 : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noMedications,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineFormScreen(
                      medicationService: widget.medicationService,
                      reminderService: widget.reminderService,
                    ),
                  ),
                ).then((_) {
                  if (mounted) setState(() {});
                });
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addMedication),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.medications,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: widget.onViewAllMedications,
              child: Text(
                l10n.viewAll,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: medications.take(5).length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return _buildMedicationCard(medication, isDarkMode, l10n);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(
      medication, bool isDarkMode, AppLocalizations l10n) {
    final reminders =
        widget.reminderService.getRemindersForMedication(medication.id);
    final activeReminders = reminders.where((r) => r.isActive).length;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: medication.color ?? AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (medication.color ?? AppTheme.primaryColor).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                medication.icon ?? Icons.medication,
                color: Colors.white,
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$activeReminders/day',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${medication.dosage.amount.toInt()} ${_getUnitString(l10n, medication.dosage.unit)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            l10n.todayReminders,
            Icons.notifications_active,
            AppTheme.primaryColor,
            () => Navigator.pushNamed(context, '/today-reminders'),
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            l10n.viewHistory,
            Icons.history,
            AppTheme.infoColor,
            () => Navigator.pushNamed(context, '/intake-history'),
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule(AppLocalizations l10n, bool isDarkMode) {
    final todayHistories = widget.intakeHistoryService.getTodayHistories();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.todaySchedule,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/today-reminders'),
                child: Text(l10n.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (todayHistories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: isDarkMode ? Colors.white54 : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noRemindersToday,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...todayHistories.take(3).map((history) {
              final medication = widget.medicationService
                  .getMedicationById(history.medicationId);
              if (medication == null) return const SizedBox.shrink();

              return _buildScheduleItem(history, medication, isDarkMode, l10n);
            }),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    IntakeHistory history,
    medication,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    final statusColor = _getStatusColor(history.status);
    final timeFormat = DateFormat.Hm();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  (medication.color ?? AppTheme.primaryColor).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              medication.icon ?? Icons.medication,
              color: medication.color ?? AppTheme.primaryColor,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeFormat.format(history.scheduledTime),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (history.status == IntakeStatus.pending) ...[
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              color: AppTheme.takenColor,
              onPressed: () async {
                await widget.intakeHistoryService.markAsTaken(history.id);
                if (mounted) setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: AppTheme.skippedColor,
              onPressed: () async {
                await widget.intakeHistoryService.markAsSkipped(history.id);
                if (mounted) setState(() {});
              },
            ),
          ] else
            StatusBadge(status: history.status.name, isSmall: true),
        ],
      ),
    );
  }

  Color _getStatusColor(IntakeStatus status) {
    switch (status) {
      case IntakeStatus.taken:
        return AppTheme.takenColor;
      case IntakeStatus.missed:
        return AppTheme.missedColor;
      case IntakeStatus.skipped:
        return AppTheme.skippedColor;
      case IntakeStatus.pending:
        return AppTheme.pendingColor;
    }
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
