import './generateId.dart';

enum MedicationTimeOfDay { morning, afternoon, evening, night, other }

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Reminder {
  final String id;
  final String medicationId; // Reference to a single medication
  final DateTime time; // Specific time for the reminder
  final int dosageAmount; // How many tablets/units to take
  final MedicationTimeOfDay timeOfDay;
  final List<WeekDay> activeDays; // Days when this reminder is active
  final bool isActive; // Whether the reminder is currently enabled

  Reminder({
    String? id,
    required this.medicationId,
    required this.time,
    required this.dosageAmount,
    required this.timeOfDay,
    required this.activeDays,
    this.isActive = true,
  }) : id = id ?? generateId.v4();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'time': time.toIso8601String(),
      'dosageAmount': dosageAmount,
      'timeOfDay': timeOfDay.name,
      'activeDays': activeDays.map((day) => day.name).toList(),
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      time: DateTime.parse(json['time'] as String),
      dosageAmount: json['dosageAmount'] as int,
      timeOfDay: MedicationTimeOfDay.values
          .firstWhere((e) => e.name == json['timeOfDay']),
      activeDays: (json['activeDays'] as List)
          .map((day) => WeekDay.values.firstWhere((e) => e.name == day))
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  // Copy with method for easy updates
  Reminder copyWith({
    String? id,
    String? medicationId,
    DateTime? time,
    int? dosageAmount,
    MedicationTimeOfDay? timeOfDay,
    List<WeekDay>? activeDays,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      time: time ?? this.time,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      activeDays: activeDays ?? this.activeDays,
      isActive: isActive ?? this.isActive,
    );
  }

  // Check if reminder should fire today
  bool shouldFireToday() {
    final today = DateTime.now();
    final weekDay =
        WeekDay.values[today.weekday - 1]; // weekday is 1-7, we need 0-6
    return isActive && activeDays.contains(weekDay);
  }
}
