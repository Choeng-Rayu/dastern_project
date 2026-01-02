import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import '../models/medication.dart';
import '../models/reminder.dart';
import '../models/intakeHistory.dart';

/// Service to handle local storage operations for user data and authentication
class StorageService {
  static const String _userDataKey = 'user_data';
  static const String _passwordKey = 'user_password';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _medicationsKey = 'medications';
  static const String _remindersKey = 'reminders';
  static const String _intakeHistoriesKey = 'intake_histories';

  /// Save complete user data including password
  Future<void> saveUserData({
    required Patient patient,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save patient data as JSON
    await prefs.setString(_userDataKey, jsonEncode(patient.toJson()));

    // Save password separately
    await prefs.setString(_passwordKey, password);

    // Mark as logged in
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Get stored patient data
  Future<Patient?> getPatientData() async {
    final prefs = await SharedPreferences.getInstance();
    final patientDataString = prefs.getString(_userDataKey);

    if (patientDataString == null) {
      return null;
    }

    return Patient.fromJson(
        jsonDecode(patientDataString) as Map<String, dynamic>);
  }

  /// Get stored password
  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Verify login credentials
  Future<bool> verifyCredentials({
    required String phone,
    required String password,
  }) async {
    final patient = await getPatientData();
    final storedPassword = await getPassword();

    if (patient == null || storedPassword == null) {
      return false;
    }

    return patient.tel == phone && storedPassword == password;
  }

  /// Clear all user data (logout)
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_passwordKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // ============ MEDICATION MANAGEMENT ============

  /// Save medications list
  Future<void> saveMedications(List<Medication> medications) async {
    final prefs = await SharedPreferences.getInstance();
    final medicationsJson = medications.map((med) => med.toJson()).toList();
    await prefs.setString(_medicationsKey, jsonEncode(medicationsJson));
  }

  /// Get medications list
  Future<List<Medication>> getMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final medicationsString = prefs.getString(_medicationsKey);

    if (medicationsString == null) {
      return [];
    }

    final List<dynamic> medicationsJson = jsonDecode(medicationsString);
    return medicationsJson
        .map((json) => Medication.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============ REMINDER MANAGEMENT ============

  /// Save reminders list
  Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = reminders.map((rem) => rem.toJson()).toList();
    await prefs.setString(_remindersKey, jsonEncode(remindersJson));
  }

  /// Get reminders list
  Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersString = prefs.getString(_remindersKey);

    if (remindersString == null) {
      return [];
    }

    final List<dynamic> remindersJson = jsonDecode(remindersString);
    return remindersJson
        .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ============ INTAKE HISTORY MANAGEMENT ============

  /// Save intake histories list
  Future<void> saveIntakeHistories(List<IntakeHistory> histories) async {
    final prefs = await SharedPreferences.getInstance();
    final historiesJson = histories.map((hist) => hist.toJson()).toList();
    await prefs.setString(_intakeHistoriesKey, jsonEncode(historiesJson));
  }

  /// Get intake histories list
  Future<List<IntakeHistory>> getIntakeHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final historiesString = prefs.getString(_intakeHistoriesKey);

    if (historiesString == null) {
      return [];
    }

    final List<dynamic> historiesJson = jsonDecode(historiesString);
    return historiesJson
        .map((json) => IntakeHistory.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
