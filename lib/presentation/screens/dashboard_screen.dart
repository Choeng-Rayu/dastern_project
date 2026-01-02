import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/l10n/app_localizations.dart';
import '/models/patient.dart';
import '/models/medication.dart';
import '/models/reminder.dart';
import '/models/intakeHistory.dart';
import '../widget/medication_card_widget.dart';
import '../widget/weight_card_widget.dart';
import '../widget/today_schedule_widget.dart';

/// Dashboard screen - Main hub of the application
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Sample data - replace with actual data from provider/database
  late Patient patient;
  late List<Medication> medications;
  late List<Reminder> reminders;
  late List<IntakeHistory> todayIntakes;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample patient
    patient = Patient(
      name: 'សុខជាត',
      dateOfBirth: DateTime(2025, 7, 8),
      tel: '012345678',
      bloodtype: 'A+',
      familyContact: '098765432',
      weight: 23.0,
    );

    // Sample medications
    medications = [
      Medication(
        id: 'med1',
        name: 'បេសមីញ៉ន',
        dosage: const Dosage(amount: 1, unit: Unit.tablet),
        instruction: 'Take with food',
        prescribeBy: 'Dr. Smith',
        color: const Color(0xFF4CAF50),
      ),
      Medication(
        id: 'med2',
        name: 'អេម៉ូប៉ូ',
        dosage: const Dosage(amount: 1, unit: Unit.tablet),
        instruction: 'Take before meal',
        prescribeBy: 'Dr. Johnson',
        color: const Color(0xFF9C27B0),
      ),
      Medication(
        id: 'med3',
        name: 'អេម៉ូប៉ូ',
        dosage: const Dosage(amount: 1, unit: Unit.tablet),
        instruction: 'Take after meal',
        prescribeBy: 'Dr. Brown',
        color: const Color(0xFFE91E63),
      ),
    ];

    // Sample reminders for today
    reminders = [
      Reminder(
        id: 'rem1',
        medicationId: 'med1',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        dosageAmount: 1,
        timeOfDay: MedicationTimeOfDay.morning,
        activeDays: WeekDay.values,
      ),
      Reminder(
        id: 'rem2',
        medicationId: 'med2',
        time: DateTime.now().add(const Duration(hours: 2)),
        dosageAmount: 1,
        timeOfDay: MedicationTimeOfDay.afternoon,
        activeDays: WeekDay.values,
      ),
      Reminder(
        id: 'rem3',
        medicationId: 'med3',
        time: DateTime.now().add(const Duration(hours: 5)),
        dosageAmount: 1,
        timeOfDay: MedicationTimeOfDay.evening,
        activeDays: WeekDay.values,
      ),
    ];

    // Sample intake history
    todayIntakes = [
      IntakeHistory(
        id: 'intake1',
        medicationId: 'med1',
        reminderId: 'rem1',
        scheduledTime: reminders[0].time,
        status: IntakeStatus.taken,
        takenAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      IntakeHistory(
        id: 'intake2',
        medicationId: 'med2',
        reminderId: 'rem2',
        scheduledTime: reminders[1].time,
        status: IntakeStatus.pending,
      ),
      IntakeHistory(
        id: 'intake3',
        medicationId: 'med3',
        reminderId: 'rem3',
        scheduledTime: reminders[2].time,
        status: IntakeStatus.pending,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF4DD0E1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 20),
                _buildGreeting(l10n),
                const SizedBox(height: 16),
                _buildPatientInfo(l10n),
                const SizedBox(height: 16),
                _buildMedicationCards(l10n),
                const SizedBox(height: 16),
                _buildWeightCard(l10n),
                const SizedBox(height: 16),
                _buildTodaySchedule(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.white,
          radius: 24,
          child: Icon(
            Icons.person,
            color: Color(0xFF4DD0E1),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.patient,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            '${l10n.hello} ${patient.name}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.notifications,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo(AppLocalizations l10n) {
    final dateFormat = DateFormat('d MM, yyyy');
    return Text(
      '${l10n.dateOfBirth}: ${dateFormat.format(patient.dateOfBirth)}',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    );
  }

  Widget _buildMedicationCards(AppLocalizations l10n) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          final intake = todayIntakes.firstWhere(
            (i) => i.medicationId == medication.id,
            orElse: () => todayIntakes[0],
          );

          return MedicationCardWidget(
            medication: medication,
            intake: intake,
          );
        },
      ),
    );
  }

  Widget _buildWeightCard(AppLocalizations l10n) {
    return WeightCardWidget(patient: patient);
  }

  Widget _buildTodaySchedule(AppLocalizations l10n) {
    return TodayScheduleWidget(
      medications: medications,
      reminders: reminders,
      todayIntakes: todayIntakes,
      onIntakeStatusChanged: (intake, value) {
        setState(() {
          final index = todayIntakes.indexOf(intake);
          todayIntakes[index] = intake.copyWith(
            status: value ? IntakeStatus.taken : IntakeStatus.pending,
            takenAt: value ? DateTime.now() : null,
          );
        });
      },
    );
  }
}
