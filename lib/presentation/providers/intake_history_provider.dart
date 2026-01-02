import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/intakeHistory.dart';
import '../../models/reminder.dart';

/// Provider to manage intake history with local storage
class IntakeHistoryProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<IntakeHistory> _histories = [];
  bool _isLoading = true;

  List<IntakeHistory> get histories => _histories;
  bool get isLoading => _isLoading;

  /// Initialize intake histories from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _histories = await _storageService.getIntakeHistories();

    _isLoading = false;
    notifyListeners();
  }

  /// Get history for a specific medication
  List<IntakeHistory> getHistoryForMedication(String medicationId) {
    return _histories
        .where((history) => history.medicationId == medicationId)
        .toList()
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
  }

  /// Get today's intake histories
  List<IntakeHistory> getTodayHistories() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _histories
        .where((history) =>
            history.scheduledTime.isAfter(today) &&
            history.scheduledTime.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Get pending intakes for today
  List<IntakeHistory> getTodayPendingIntakes() {
    return getTodayHistories()
        .where((history) => history.status == IntakeStatus.pending)
        .toList();
  }

  /// Get completed intakes for today
  List<IntakeHistory> getTodayCompletedIntakes() {
    return getTodayHistories()
        .where((history) => history.status == IntakeStatus.taken)
        .toList();
  }

  /// Get history statistics for a date range
  Map<String, int> getStatistics(DateTime startDate, DateTime endDate) {
    final rangeHistories = _histories.where((history) {
      return history.scheduledTime.isAfter(startDate) &&
          history.scheduledTime.isBefore(endDate);
    }).toList();

    return {
      'total': rangeHistories.length,
      'taken':
          rangeHistories.where((h) => h.status == IntakeStatus.taken).length,
      'missed':
          rangeHistories.where((h) => h.status == IntakeStatus.missed).length,
      'skipped':
          rangeHistories.where((h) => h.status == IntakeStatus.skipped).length,
      'pending':
          rangeHistories.where((h) => h.status == IntakeStatus.pending).length,
    };
  }

  /// Calculate adherence rate (percentage of taken medications)
  double getAdherenceRate(DateTime startDate, DateTime endDate) {
    final stats = getStatistics(startDate, endDate);
    final total = stats['total'] ?? 0;
    if (total == 0) return 0.0;

    final taken = stats['taken'] ?? 0;
    return (taken / total * 100);
  }

  /// Create intake history entries for today's reminders
  Future<void> generateTodayIntakes(List<Reminder> reminders) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if we already have histories for today
    final todayHistories = getTodayHistories();
    if (todayHistories.isNotEmpty) {
      return; // Already generated
    }

    // Create history for each active reminder that should fire today
    for (var reminder in reminders) {
      if (reminder.shouldFireToday()) {
        final scheduledTime = DateTime(
          today.year,
          today.month,
          today.day,
          reminder.time.hour,
          reminder.time.minute,
        );

        final history = IntakeHistory(
          medicationId: reminder.medicationId,
          reminderId: reminder.id,
          scheduledTime: scheduledTime,
          status: IntakeStatus.pending,
        );

        await addHistory(history);
      }
    }
  }

  /// Add new intake history
  Future<void> addHistory(IntakeHistory history) async {
    _histories.add(history);
    await _storageService.saveIntakeHistories(_histories);
    notifyListeners();
  }

  /// Mark intake as taken
  Future<void> markAsTaken(String historyId) async {
    final index = _histories.indexWhere((h) => h.id == historyId);
    if (index != -1) {
      _histories[index] = _histories[index].copyWith(
        status: IntakeStatus.taken,
        takenAt: DateTime.now(),
      );
      await _storageService.saveIntakeHistories(_histories);
      notifyListeners();
    }
  }

  /// Mark intake as skipped
  Future<void> markAsSkipped(String historyId) async {
    final index = _histories.indexWhere((h) => h.id == historyId);
    if (index != -1) {
      _histories[index] = _histories[index].copyWith(
        status: IntakeStatus.skipped,
      );
      await _storageService.saveIntakeHistories(_histories);
      notifyListeners();
    }
  }

  /// Mark missed intakes (for past scheduled times that are still pending)
  Future<void> updateMissedIntakes() async {
    final now = DateTime.now();
    bool hasChanges = false;

    for (int i = 0; i < _histories.length; i++) {
      if (_histories[i].status == IntakeStatus.pending &&
          _histories[i]
              .scheduledTime
              .isBefore(now.subtract(const Duration(hours: 1)))) {
        _histories[i] = _histories[i].copyWith(
          status: IntakeStatus.missed,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _storageService.saveIntakeHistories(_histories);
      notifyListeners();
    }
  }

  /// Update existing history
  Future<void> updateHistory(IntakeHistory history) async {
    final index = _histories.indexWhere((h) => h.id == history.id);
    if (index != -1) {
      _histories[index] = history;
      await _storageService.saveIntakeHistories(_histories);
      notifyListeners();
    }
  }

  /// Delete history
  Future<void> deleteHistory(String historyId) async {
    _histories.removeWhere((h) => h.id == historyId);
    await _storageService.saveIntakeHistories(_histories);
    notifyListeners();
  }

  /// Delete all histories for a medication
  Future<void> deleteHistoriesForMedication(String medicationId) async {
    _histories.removeWhere((h) => h.medicationId == medicationId);
    await _storageService.saveIntakeHistories(_histories);
    notifyListeners();
  }

  /// Clear all histories
  Future<void> clearAllHistories() async {
    _histories.clear();
    await _storageService.saveIntakeHistories(_histories);
    notifyListeners();
  }
}
