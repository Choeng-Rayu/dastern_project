import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../providers/medication_provider.dart';
import '../providers/reminder_provider.dart';
import '../../models/medication.dart';
import '../../models/reminder.dart';
import '../../services/notification_service.dart';
import '../widget/gradient_background.dart';

/// Medicine Form screen - Create new medication with custom reminder times
class MedicineFormScreen extends StatefulWidget {
  final Medication? medication;

  const MedicineFormScreen({super.key, this.medication});

  @override
  State<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class ReminderTime {
  TimeOfDay time;
  MedicationTimeOfDay timeOfDay;
  List<WeekDay> activeDays;
  int dosageAmount;

  ReminderTime({
    required this.time,
    required this.timeOfDay,
    required this.activeDays,
    this.dosageAmount = 1,
  });
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _instructionController = TextEditingController();
  final _prescriberController = TextEditingController();

  Unit _selectedUnit = Unit.tablet;
  bool _isLoading = false;

  // Reminder times list
  List<ReminderTime> _reminderTimes = [];

  // Available colors for medication
  final List<Color> _availableColors = [
    const Color(0xFF4DD0E1), // Cyan
    const Color(0xFF4CAF50), // Green
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFFFF9800), // Orange
    const Color(0xFF2196F3), // Blue
    const Color(0xFFF44336), // Red
    const Color(0xFF00BCD4), // Teal
  ];

  Color _selectedColor = const Color(0xFF4DD0E1);
  IconData _selectedIcon = Icons.medication;

  // Available icons for medication
  final List<IconData> _availableIcons = [
    Icons.medication,
    Icons.medication_liquid,
    Icons.vaccines,
    Icons.local_hospital,
    Icons.healing,
    Icons.medical_services,
    Icons.science,
    Icons.colorize,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      // Pre-populate form for edit mode
      _nameController.text = widget.medication!.name;
      _amountController.text = widget.medication!.dosage.amount.toString();
      _selectedUnit = widget.medication!.dosage.unit;
      _instructionController.text = widget.medication!.instruction;
      _prescriberController.text = widget.medication!.prescribeBy;
      _selectedColor = widget.medication!.color ?? const Color(0xFF4DD0E1);
      _selectedIcon = widget.medication!.icon ?? Icons.medication;

      // Load existing reminders
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final reminderProvider =
            Provider.of<ReminderProvider>(context, listen: false);
        final existingReminders =
            reminderProvider.getRemindersForMedication(widget.medication!.id);

        setState(() {
          _reminderTimes = existingReminders.map((reminder) {
            return ReminderTime(
              time: TimeOfDay.fromDateTime(reminder.time),
              timeOfDay: reminder.timeOfDay,
              activeDays: List.from(reminder.activeDays), // Mutable copy
              dosageAmount: reminder.dosageAmount,
            );
          }).toList();
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _instructionController.dispose();
    _prescriberController.dispose();
    super.dispose();
  }

  void _addReminderTime() {
    setState(() {
      _reminderTimes.add(ReminderTime(
        time: const TimeOfDay(hour: 8, minute: 0),
        timeOfDay: MedicationTimeOfDay.morning,
        activeDays:
            List.from(WeekDay.values), // Mutable copy - All days by default
        dosageAmount: 1,
      ));
    });
  }

  void _removeReminderTime(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  Future<void> _pickTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index].time,
    );
    if (picked != null) {
      setState(() {
        _reminderTimes[index].time = picked;
        // Auto-calculate time of day based on the hour
        _reminderTimes[index].timeOfDay = _getTimeOfDayFromHour(picked.hour);
      });
    }
  }

  /// Auto-calculate MedicationTimeOfDay based on hour
  MedicationTimeOfDay _getTimeOfDayFromHour(int hour) {
    if (hour >= 5 && hour < 12) {
      return MedicationTimeOfDay.morning; // 5:00 AM - 11:59 AM
    } else if (hour >= 12 && hour < 17) {
      return MedicationTimeOfDay.afternoon; // 12:00 PM - 4:59 PM
    } else if (hour >= 17 && hour < 20) {
      return MedicationTimeOfDay.evening; // 5:00 PM - 7:59 PM
    } else {
      return MedicationTimeOfDay.night; // 8:00 PM - 4:59 AM
    }
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      if (_reminderTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addAtLeastOneReminder),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final l10n = AppLocalizations.of(context)!;
      final medicationProvider =
          Provider.of<MedicationProvider>(context, listen: false);
      final reminderProvider =
          Provider.of<ReminderProvider>(context, listen: false);

      final dosage = Dosage(
        amount: double.parse(_amountController.text),
        unit: _selectedUnit,
      );

      final isEditing = widget.medication != null;
      final Medication medication;

      if (isEditing) {
        // Update existing medication
        medication = widget.medication!.copyWith(
          name: _nameController.text.trim(),
          dosage: dosage,
          instruction: _instructionController.text.trim(),
          prescribeBy: _prescriberController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
        );
        await medicationProvider.updateMedication(medication);

        // Delete old reminders before creating new ones
        await reminderProvider.deleteRemindersForMedication(medication.id);
      } else {
        // Create new medication
        medication = Medication(
          name: _nameController.text.trim(),
          dosage: dosage,
          instruction: _instructionController.text.trim(),
          prescribeBy: _prescriberController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
        );
        await medicationProvider.addMedication(medication);
      }

      if (!context.mounted) return;
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);

      // Create reminders with custom times and schedule notifications
      for (final reminderTime in _reminderTimes) {
        final now = DateTime.now();
        final reminderDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          reminderTime.time.hour,
          reminderTime.time.minute,
        );

        final reminder = Reminder(
          medicationId: medication.id,
          time: reminderDateTime,
          dosageAmount: reminderTime.dosageAmount,
          timeOfDay: reminderTime.timeOfDay,
          activeDays: reminderTime.activeDays,
          isActive: true,
        );

        await reminderProvider.addReminder(reminder);

        // Schedule notification for this reminder if it's for today
        if (reminder.shouldFireToday() && reminderDateTime.isAfter(now)) {
          await notificationService.scheduleReminder(
            id: reminder.id,
            medicationName: medication.name,
            scheduledTime: reminderDateTime,
            dosageInfo:
                '${reminderTime.dosageAmount} ${_getUnitString(medication.dosage.unit)}',
            medicationId: medication.id,
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isEditing ? l10n.medicationUpdated : l10n.medicationAdded),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        if (isEditing) {
          // Pop back to previous screen after editing
          Navigator.pop(context);
        } else {
          // Clear form for next entry when adding
          _nameController.clear();
          _amountController.clear();
          _instructionController.clear();
          _prescriberController.clear();
          setState(() {
            _selectedUnit = Unit.tablet;
            _reminderTimes.clear();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
        body: GradientBackground(
      isDarkMode: isDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (widget.medication == null)
                    const Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 32)
                  else
                    const Icon(Icons.edit, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    widget.medication == null
                        ? l10n.addMedication
                        : l10n.editMedication,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medication name
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.medicationName,
                            hintText: l10n.enterMedicationName,
                            prefixIcon: Icon(
                              Icons.medication,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            labelStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            hintStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[800] : Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.fieldRequired;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Dosage section
                        Text(
                          l10n.dosage,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            // Amount
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _amountController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  labelText: l10n.amount,
                                  hintText: l10n.enterAmount,
                                  prefixIcon: Icon(
                                    Icons.numbers,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.fieldRequired;
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Unit
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<Unit>(
                                initialValue: _selectedUnit,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                dropdownColor:
                                    isDark ? Colors.grey[800] : Colors.white,
                                decoration: InputDecoration(
                                  labelText: l10n.unit,
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[50],
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: Unit.tablet,
                                    child: Text(l10n.tablet),
                                  ),
                                  DropdownMenuItem(
                                    value: Unit.ml,
                                    child: Text(l10n.ml),
                                  ),
                                  DropdownMenuItem(
                                    value: Unit.mg,
                                    child: Text(l10n.mg),
                                  ),
                                  DropdownMenuItem(
                                    value: Unit.other,
                                    child: Text(l10n.other),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedUnit = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Instruction
                        TextFormField(
                          controller: _instructionController,
                          maxLines: 3,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.instruction,
                            hintText: l10n.enterInstruction,
                            prefixIcon: Icon(
                              Icons.info_outline,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            labelStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            hintStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[800] : Colors.grey[50],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Prescribed by
                        TextFormField(
                          controller: _prescriberController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.prescribedBy,
                            hintText: l10n.enterPrescriber,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            labelStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            hintStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[800] : Colors.grey[50],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Color picker
                        Text(
                          'Color',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 56,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _availableColors.map((color) {
                                final isSelected = color == _selectedColor;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedColor = color),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDark
                                                ? Colors.white
                                                : Colors.black)
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: color.withOpacity(0.5),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 28)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Icon picker
                        Text(
                          'Icon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 56,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _availableIcons.length,
                            itemBuilder: (context, index) {
                              final icon = _availableIcons[index];
                              final isSelected = icon == _selectedIcon;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIcon = icon;
                                  });
                                },
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _selectedColor.withOpacity(0.2)
                                        : (isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200]),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? _selectedColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: isSelected
                                        ? _selectedColor
                                        : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                    size: 28,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Reminder Times Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.reminders,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addReminderTime,
                              icon: const Icon(Icons.add),
                              label: Text(l10n.addTime),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List of reminder times
                        if (_reminderTimes.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.alarm_add,
                                      size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.noRemindersAdded,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...List.generate(_reminderTimes.length, (index) {
                            final reminderTime = _reminderTimes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${l10n.reminder} ${index + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _removeReminderTime(index),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Time picker
                                    InkWell(
                                      onTap: () => _pickTime(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              _selectedColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: _selectedColor),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                color: _selectedColor),
                                            const SizedBox(width: 12),
                                            Text(
                                              reminderTime.time.format(context),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedColor,
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(Icons.edit,
                                                color: _selectedColor,
                                                size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Time of day dropdown
                                    DropdownButtonFormField<
                                        MedicationTimeOfDay>(
                                      initialValue: reminderTime.timeOfDay,
                                      decoration: InputDecoration(
                                        labelText: l10n.timeOfDay,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: MedicationTimeOfDay.morning,
                                          child: Text(l10n.morning),
                                        ),
                                        DropdownMenuItem(
                                          value: MedicationTimeOfDay.afternoon,
                                          child: Text(l10n.afternoon),
                                        ),
                                        DropdownMenuItem(
                                          value: MedicationTimeOfDay.evening,
                                          child: Text(l10n.evening),
                                        ),
                                        DropdownMenuItem(
                                          value: MedicationTimeOfDay.night,
                                          child: Text(l10n.night),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            // Validate: Check if manually selected time of day matches the actual time
                                            final correctTimeOfDay =
                                                _getTimeOfDayFromHour(
                                                    _reminderTimes[index]
                                                        .time
                                                        .hour);

                                            if (value != correctTimeOfDay) {
                                              // Show warning and auto-correct
                                              _reminderTimes[index].timeOfDay =
                                                  correctTimeOfDay;

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Time of day auto-corrected to match ${_reminderTimes[index].time.format(context)}',
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
                                                  duration: const Duration(
                                                      seconds: 2),
                                                ),
                                              );
                                            } else {
                                              _reminderTimes[index].timeOfDay =
                                                  value;
                                            }
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Dosage amount
                                    TextFormField(
                                      initialValue:
                                          reminderTime.dosageAmount.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: l10n.dosageAmount,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                      ),
                                      onChanged: (value) {
                                        final amount = int.tryParse(value) ?? 1;
                                        setState(() {
                                          _reminderTimes[index].dosageAmount =
                                              amount;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Active days
                                    Text(
                                      l10n.activeDays,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.start,
                                      children: WeekDay.values.map((day) {
                                        final isActive = reminderTime.activeDays
                                            .contains(day);
                                        return SizedBox(
                                          width: 60,
                                          child: FilterChip(
                                            label: SizedBox(
                                              width: 30,
                                              child: Text(
                                                _getDayAbbreviation(day),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: isActive
                                                      ? Colors.white
                                                      : Colors.grey[700],
                                                  fontWeight: isActive
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            selected: isActive,
                                            selectedColor: _selectedColor,
                                            checkmarkColor: Colors.white,
                                            backgroundColor: Colors.grey[200],
                                            side: BorderSide(
                                              color: isActive
                                                  ? _selectedColor
                                                  : Colors.grey[300]!,
                                              width: 1.5,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 8),
                                            showCheckmark: true,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  _reminderTimes[index]
                                                      .activeDays
                                                      .add(day);
                                                } else {
                                                  _reminderTimes[index]
                                                      .activeDays
                                                      .remove(day);
                                                }
                                              });
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                        const SizedBox(height: 32),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveMedication,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    l10n.save,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _getDayAbbreviation(WeekDay day) {
    switch (day) {
      case WeekDay.monday:
        return 'Mon';
      case WeekDay.tuesday:
        return 'Tue';
      case WeekDay.wednesday:
        return 'Wed';
      case WeekDay.thursday:
        return 'Thu';
      case WeekDay.friday:
        return 'Fri';
      case WeekDay.saturday:
        return 'Sat';
      case WeekDay.sunday:
        return 'Sun';
    }
  }

  String _getUnitString(Unit unit) {
    switch (unit) {
      case Unit.tablet:
        return 'tablet';
      case Unit.ml:
        return 'ml';
      case Unit.mg:
        return 'mg';
      case Unit.other:
        return 'other';
    }
  }
}
