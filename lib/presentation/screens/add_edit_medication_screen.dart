import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import '../providers/medication_provider.dart';
import '../providers/reminder_provider.dart';
import '../../models/medication.dart';

/// Add/Edit Medication Screen with auto-reminder generation
class AddEditMedicationScreen extends StatefulWidget {
  final Medication? medication;

  const AddEditMedicationScreen({super.key, this.medication});

  @override
  State<AddEditMedicationScreen> createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _instructionController = TextEditingController();
  final _prescriberController = TextEditingController();

  Unit _selectedUnit = Unit.tablet;
  bool _autoGenerateReminders = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _amountController.text = widget.medication!.dosage.amount.toString();
      _selectedUnit = widget.medication!.dosage.unit;
      _instructionController.text = widget.medication!.instruction;
      _prescriberController.text = widget.medication!.prescribeBy;
      _autoGenerateReminders = false; // Don't regenerate for existing meds
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

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
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

      if (widget.medication == null) {
        // Add new medication
        final newMedication = Medication(
          name: _nameController.text.trim(),
          dosage: dosage,
          instruction: _instructionController.text.trim(),
          prescribeBy: _prescriberController.text.trim(),
          color: const Color(0xFF4DD0E1),
          icon: Icons.medication,
        );

        await medicationProvider.addMedication(newMedication);

        // Auto-generate reminders if enabled
        if (_autoGenerateReminders) {
          await reminderProvider.autoGenerateReminders(
            medication: newMedication,
            dosageAmount: 1,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.remindersGenerated),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.medicationAdded),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing medication
        final updatedMedication = widget.medication!.copyWith(
          name: _nameController.text.trim(),
          dosage: dosage,
          instruction: _instructionController.text.trim(),
          prescribeBy: _prescriberController.text.trim(),
        );

        await medicationProvider.updateMedication(updatedMedication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.medicationUpdated),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.medication != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editMedication : l10n.addMedication),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.medicationName,
                  hintText: l10n.enterMedicationName,
                  prefixIcon: const Icon(Icons.medication),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        hintText: l10n.enterAmount,
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: l10n.unit,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                decoration: InputDecoration(
                  labelText: l10n.instruction,
                  hintText: l10n.enterInstruction,
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),

              const SizedBox(height: 16),

              // Prescribed by
              TextFormField(
                controller: _prescriberController,
                decoration: InputDecoration(
                  labelText: l10n.prescribedBy,
                  hintText: l10n.enterPrescriber,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),

              const SizedBox(height: 24),

              // Auto-generate reminders (only for new medications)
              if (!isEditing)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.reminders,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.autoGenerateReminders,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _autoGenerateReminders,
                        onChanged: (value) {
                          setState(() {
                            _autoGenerateReminders = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1),
                    foregroundColor: Colors.white,
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
    );
  }
}
