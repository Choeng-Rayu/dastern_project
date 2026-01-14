import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/medication_service.dart';
import '../../services/reminder_service.dart';
import '../../services/notification_service.dart';
import '../../models/medication.dart';
import '../../models/reminder.dart';
import './medicine_form_screen.dart';

/// Medications screen - Lists all medications with CRUD operations
class MedicationsScreen extends StatefulWidget {
  final MedicationService medicationService;
  final ReminderService reminderService;
  final NotificationService? notificationService;
  final VoidCallback? onMedicationChanged;
  final GlobalKey<NavigatorState>? navigatorKey;
  final VoidCallback? onNavigateToForm;
  final VoidCallback? onReturnFromForm;

  const MedicationsScreen({
    super.key,
    required this.medicationService,
    required this.reminderService,
    this.notificationService,
    this.onMedicationChanged,
    this.navigatorKey,
    this.onNavigateToForm,
    this.onReturnFromForm,
  });

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  Future<void> _refreshMedications() async {
    // Re-initialize the services to load fresh data from storage
    await widget.medicationService.initialize();
    await widget.reminderService.initialize();

    if (mounted) {
      setState(() {}); // Refresh UI
    }
  }

  void _onMedicationSaved() {
    // Refresh the list when a medication is saved
    setState(() {});
    widget.onMedicationChanged?.call();
  }

  /// Navigate to medicine form using nested navigator if available
  void _navigateToForm({Medication? medication}) {
    final formScreen = MedicineFormScreen(
      medication: medication,
      medicationService: widget.medicationService,
      reminderService: widget.reminderService,
      notificationService: widget.notificationService,
      onSaved: _onMedicationSaved,
    );

    // Notify parent that we're navigating to form (to highlight Add Medicine tab)
    widget.onNavigateToForm?.call();

    // Use nested navigator if available, otherwise use regular Navigator
    if (widget.navigatorKey?.currentState != null) {
      widget.navigatorKey!.currentState!.push(
        MaterialPageRoute(builder: (context) => formScreen),
      ).then((_) {
        // Notify parent that we've returned from form
        widget.onReturnFromForm?.call();
        if (mounted) setState(() {});
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => formScreen),
      ).then((_) {
        widget.onReturnFromForm?.call();
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medications = widget.medicationService.medications;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Part of bottom navigation
        title: Text(l10n.medications),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMedications,
        child: medications.isEmpty
            ? ListView(
                // Use ListView to enable pull-to-refresh even when empty
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noMedications,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.pullToRefresh,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  return _MedicationCard(
                    medication: medication,
                    reminderService: widget.reminderService,
                    onTap: () {
                      _navigateToForm(medication: medication);
                    },
                    onDelete: () => _showDeleteDialog(context, medication),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToForm();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addMedication),
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, Medication medication) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedication),
        content: Text(l10n.deleteMedicationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Delete medication and its reminders
      await widget.medicationService.deleteMedication(medication.id);
      await widget.reminderService.deleteRemindersForMedication(medication.id);

      if (context.mounted) {
        setState(() {}); // Refresh UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicationDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final ReminderService reminderService;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.reminderService,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reminders = reminderService.getRemindersForMedication(medication.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (medication.instruction.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          medication.instruction,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (medication.prescribeBy.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.prescribedBy}: ${medication.prescribeBy}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Reminders section
              if (reminders.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: medication.color ?? const Color(0xFF4DD0E1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.reminders,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (medication.color ?? const Color(0xFF4DD0E1))
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${reminders.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: medication.color ?? const Color(0xFF4DD0E1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...reminders.take(3).map((reminder) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 24),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatTime(reminder.time)} - ${_getMealTimeString(l10n, reminder.mealTime)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${reminder.dosageAmount}x',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (reminders.length > 3) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      '+${reminders.length - 3} more',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getMealTimeString(AppLocalizations l10n, MealTime mealTime) {
    switch (mealTime) {
      case MealTime.breakfast:
        return l10n.breakfast;
      case MealTime.lunch:
        return l10n.lunch;
      case MealTime.dinner:
        return l10n.dinner;
      case MealTime.bedtime:
        return l10n.bedtime;
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
