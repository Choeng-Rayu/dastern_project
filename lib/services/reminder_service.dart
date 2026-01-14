import 'storage_service.dart';
import '../models/reminder.dart';
import '../models/medication.dart';

/// Service to manage reminders with auto-generation from medications
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final StorageService _storageService = StorageService();

  List<Reminder> _reminders = [];
  bool _isLoading = true;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  /// Initialize reminders from storage
  Future<void> initialize() async {
    _isLoading = true;

    _reminders = await _storageService.getReminders();

    _isLoading = false;
  }

  /// Get reminders for a specific medication
  List<Reminder> getRemindersForMedication(String medicationId) {
    return _reminders.where((rem) => rem.medicationId == medicationId).toList();
  }

  /// Get active reminders for today
  List<Reminder> getTodayReminders() {
    return _reminders.where((rem) => rem.shouldFireToday()).toList();
  }

  /// Auto-generate default reminders when a medication is created
  /// Creates 3 reminders: morning, afternoon, evening
  Future<List<Reminder>> autoGenerateReminders({
    required Medication medication,
    int dosageAmount = 1,
  }) async {
    final now = DateTime.now();

    // Define default times
    final morningTime = DateTime(now.year, now.month, now.day, 8, 0); // 8:00 AM
    final afternoonTime =
        DateTime(now.year, now.month, now.day, 12, 0); // 12:00 PM
    final eveningTime =
        DateTime(now.year, now.month, now.day, 18, 0); // 6:00 PM

    // All days of the week
    const allDays = WeekDay.values;

    final reminders = [
      Reminder(
        medicationId: medication.id,
        time: morningTime,
        dosageAmount: dosageAmount,
        mealTime: MealTime.breakfast,
        activeDays: allDays,
        isActive: true,
      ),
      Reminder(
        medicationId: medication.id,
        time: afternoonTime,
        dosageAmount: dosageAmount,
        mealTime: MealTime.lunch,
        activeDays: allDays,
        isActive: true,
      ),
      Reminder(
        medicationId: medication.id,
        time: eveningTime,
        dosageAmount: dosageAmount,
        mealTime: MealTime.dinner,
        activeDays: allDays,
        isActive: true,
      ),
    ];

    for (var reminder in reminders) {
      await addReminder(reminder);
    }

    return reminders;
  }

  /// Add new reminder
  Future<Reminder> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    await _storageService.saveReminders(_reminders);
    return reminder;
  }

  /// Update existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((rem) => rem.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await _storageService.saveReminders(_reminders);
    }
  }

  /// Delete reminder
  Future<void> deleteReminder(String reminderId) async {
    _reminders.removeWhere((rem) => rem.id == reminderId);
    await _storageService.saveReminders(_reminders);
  }

  /// Delete all reminders for a medication
  Future<void> deleteRemindersForMedication(String medicationId) async {
    _reminders.removeWhere((rem) => rem.medicationId == medicationId);
    await _storageService.saveReminders(_reminders);
  }

  /// Toggle reminder active status
  Future<void> toggleReminderActive(String reminderId) async {
    final index = _reminders.indexWhere((rem) => rem.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        isActive: !_reminders[index].isActive,
      );
      await _storageService.saveReminders(_reminders);
    }
  }

  /// Clear all reminders
  Future<void> clearAllReminders() async {
    _reminders.clear();
    await _storageService.saveReminders(_reminders);
  }
}
