import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/l10n/app_localizations.dart';
import '/models/patient.dart';
import '/models/medication.dart';
import '/models/reminder.dart';
import '/models/intakeHistory.dart';

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
    return const Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 24,
          child: Icon(
            Icons.person,
            color: const Color(0xFF4DD0E1),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'អ្នកជំងឺ', // Patient in Khmer
          style: TextStyle(
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
            'សួស្តី ${patient.name} !', // Hello in Khmer
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
      'ថ្ងៃកំណើត: ${dateFormat.format(patient.dateOfBirth)}', // Date of birth in Khmer
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted
                        ? 'បានបញ្ចប់'
                        : 'រងចាំ', // Completed/Pending in Khmer
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
        },
      ),
    );
  }

  Widget _buildWeightCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Weight circle
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 0.7,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text(
                  '${patient.weight?.toInt() ?? 0} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Health metrics
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHealthMetric(
                  'ការបង្ការផ្តុំនូវឬសឬស្សីអាចជួយ',
                  'បង្កើតការថែទាំអ្នកជំងឺ',
                  Icons.check_circle,
                ),
                const SizedBox(height: 8),
                _buildHealthMetric(
                  'សុខភាពល្អបង្កើតអាហារបែបនេះ',
                  'អាហារ ២ ដងក្នុងមួយថ្ងៃ',
                  Icons.restaurant,
                ),
                const SizedBox(height: 8),
                _buildHealthMetric(
                  'ហេតុផលដែលធ្វើឲ្យសុខភាពល្អបើ',
                  '',
                  Icons.favorite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySchedule(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF4DD0E1),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'កាលវិភាគ (ថ្ងៃនេះ)', // Schedule (Today) in Khmer
                style: TextStyle(
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
            return _buildMedicineScheduleItem(
              medication,
              reminder,
              intake,
              l10n,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMedicineScheduleItem(
    Medication medication,
    Reminder reminder,
    IntakeHistory intake,
    AppLocalizations l10n,
  ) {
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
                  '${reminder.dosageAmount} ដុំ', // dose in Khmer
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
            onChanged: (value) {
              // Handle checkbox toggle
              setState(() {
                final index = todayIntakes.indexOf(intake);
                todayIntakes[index] = intake.copyWith(
                  status: value! ? IntakeStatus.taken : IntakeStatus.pending,
                  takenAt: value ? DateTime.now() : null,
                );
              });
            },
            activeColor: const Color(0xFF4DD0E1),
          ),
        ],
      ),
    );
  }
}
