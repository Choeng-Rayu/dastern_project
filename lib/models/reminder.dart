import './generateId.dart';

/// Meal time for medication reminders
enum MealTime { breakfast, lunch, dinner, bedtime }

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Reminder {
  final String id;
  final String medicationId; // Reference to a single medication
  final DateTime time; // Specific time for the reminder
  final int dosageAmount; // How many tablets/units to take per reminder
  final MealTime mealTime; // Which meal this reminder is associated with
  final List<WeekDay> activeDays; // Days when this reminder is active
  final bool isActive; // Whether the reminder is currently enabled

  Reminder({
    String? id,
    required this.medicationId,
    required this.time,
    required this.dosageAmount,
    required this.mealTime,
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
      'mealTime': mealTime.name,
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
      mealTime: MealTime.values
          .firstWhere((e) => e.name == json['mealTime'],
              orElse: () => MealTime.breakfast),
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
    MealTime? mealTime,
    List<WeekDay>? activeDays,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      time: time ?? this.time,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      mealTime: mealTime ?? this.mealTime,
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
