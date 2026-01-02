import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import '../models/medication.dart';
import '../models/reminder.dart';
import '../models/intakeHistory.dart';

/// Service to handle local storage operations for user data and authentication
class StorageService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserPhoneKey = 'current_user_phone';

  /// Get user-specific key for user data
  String _getUserDataKey(String userPhone) => 'user_data_$userPhone';

  /// Get user-specific key for password
  String _getPasswordKey(String userPhone) => 'user_password_$userPhone';

  /// Get user-specific key for medications
  String _getMedicationsKey(String userPhone) => 'medications_$userPhone';

  /// Get user-specific key for reminders
  String _getRemindersKey(String userPhone) => 'reminders_$userPhone';

  /// Get user-specific key for intake histories
  String _getIntakeHistoriesKey(String userPhone) =>
      'intake_histories_$userPhone';

  /// Log debug information
  void _log(String message) {
    debugPrint('🔐 [StorageService] $message');
  }

  /// Save complete user data including password
  Future<void> saveUserData({
    required Patient patient,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _log('Saving user data for phone: ${patient.tel}');

      // Save patient data as JSON with user-specific key
      final userDataKey = _getUserDataKey(patient.tel);
      await prefs.setString(userDataKey, jsonEncode(patient.toJson()));

      // Save password separately with user-specific key
      final passwordKey = _getPasswordKey(patient.tel);
      await prefs.setString(passwordKey, password);

      // Save current user phone
      await prefs.setString(_currentUserPhoneKey, patient.tel);

      // Mark as logged in
      await prefs.setBool(_isLoggedInKey, true);

      _log('✅ User data saved successfully');
    } catch (e) {
      _log('❌ Error saving user data: $e');
      rethrow;
    }
  }

  /// Get stored patient data for current user
  Future<Patient?> getPatientData() async {
    try {
      final userPhone = await getCurrentUserPhone();
      if (userPhone == null) {
        _log('No current user phone found');
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final userDataKey = _getUserDataKey(userPhone);
      final patientDataString = prefs.getString(userDataKey);

      if (patientDataString == null) {
        _log('No patient data found for: $userPhone');
        return null;
      }

      final patient = Patient.fromJson(
          jsonDecode(patientDataString) as Map<String, dynamic>);
      _log('✅ Patient data loaded: ${patient.tel}');
      return patient;
    } catch (e) {
      _log('❌ Error loading patient data: $e');
      return null;
    }
  }

  /// Get stored password for current user
  Future<String?> getPassword() async {
    try {
      final userPhone = await getCurrentUserPhone();
      if (userPhone == null) {
        _log('No current user phone found');
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final passwordKey = _getPasswordKey(userPhone);
      final password = prefs.getString(passwordKey);
      _log('Password loaded: ${password != null ? "✅ Found" : "❌ Not found"}');
      return password;
    } catch (e) {
      _log('❌ Error loading password: $e');
      return null;
    }
  }

  /// Get current user phone
  Future<String?> getCurrentUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserPhoneKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      _log('Is logged in: $loggedIn');
      return loggedIn;
    } catch (e) {
      _log('❌ Error checking login status: $e');
      return false;
    }
  }

  /// Verify login credentials
  Future<bool> verifyCredentials({
    required String phone,
    required String password,
  }) async {
    try {
      _log('Verifying credentials for phone: $phone');

      final prefs = await SharedPreferences.getInstance();

      // Load user-specific data
      final userDataKey = _getUserDataKey(phone);
      final passwordKey = _getPasswordKey(phone);

      final patientDataString = prefs.getString(userDataKey);
      final storedPassword = prefs.getString(passwordKey);

      _log('User data found: ${patientDataString != null}');
      _log(
          'Stored password: ${storedPassword != null ? "Found" : "Not found"}');

      if (patientDataString == null || storedPassword == null) {
        _log('❌ Verification failed: User not registered');
        return false;
      }

      final passwordMatch = storedPassword == password;
      _log('Password match: $passwordMatch');

      if (passwordMatch) {
        // Set current user phone on successful login
        await prefs.setString(_currentUserPhoneKey, phone);
        await prefs.setBool(_isLoggedInKey, true);
        _log('✅ Credentials valid, user set as current');
      } else {
        _log('❌ Credentials invalid');
      }

      return passwordMatch;
    } catch (e) {
      _log('❌ Error verifying credentials: $e');
      return false;
    }
  }

  /// Clear login session (logout) - keeps user data intact
  Future<void> clearAuthData() async {
    try {
      final userPhone = await getCurrentUserPhone();
      final prefs = await SharedPreferences.getInstance();
      _log('Logging out user: $userPhone');

      // Only clear login status and current user, NOT the user data itself
      await prefs.remove(_currentUserPhoneKey);
      await prefs.setBool(_isLoggedInKey, false);

      _log('✅ User logged out (data preserved)');
    } catch (e) {
      _log('❌ Error clearing auth data: $e');
      rethrow;
    }
  }

  // ============ MEDICATION MANAGEMENT ============

  /// Save medications list for current user
  Future<void> saveMedications(List<Medication> medications) async {
    try {
      final userPhone = await getCurrentUserPhone();
      if (userPhone == null) {
        _log('❌ Cannot save medications: No user logged in');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = medications.map((med) => med.toJson()).toList();
      final key = _getMedicationsKey(userPhone);
      await prefs.setString(key, jsonEncode(medicationsJson));

      _log('✅ Saved ${medications.length} medications for user: $userPhone');
    } catch (e) {
      _log('❌ Error saving medications: $e');
      rethrow;
    }
  }

  /// Get medications list for current user
  Future<List<Medication>> getMedications() async {
    try {
      final userPhone = await getCurrentUserPhone();
      if (userPhone == null) {
        _log('❌ Cannot load medications: No user logged in');
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final key = _getMedicationsKey(userPhone);
      final medicationsString = prefs.getString(key);

      if (medicationsString == null) {
        _log('No medications found for user: $userPhone');
        return [];
      }

      final List<dynamic> medicationsJson = jsonDecode(medicationsString);
      final medications = medicationsJson
          .map((json) => Medication.fromJson(json as Map<String, dynamic>))
          .toList();

      _log('✅ Loaded ${medications.length} medications for user: $userPhone');
      return medications;
    } catch (e) {
      _log('❌ Error loading medications: $e');
      return [];
    }
  }

  // ============ REMINDER MANAGEMENT ============

  /// Save reminders list for current user
  Future<void> saveReminders(List<Reminder> reminders) async {
    try {
      final userPhone = await getCurrentUserPhone();
      if (userPhone == null) {
        _log('❌ Cannot save reminders: No user logged in');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final remindersJson = reminders.map((rem) => rem.toJson()).toList();
      final key = _getRemindersKey(userPhone);
      await prefs.setString(key, jsonEncode(remindersJson));

      _log('✅ Saved ${reminders.length} reminders for user: $userPhone');
    } catch (e) {
      _log('❌ Error saving reminders: $e');
      rethrow;
    }
  }

  /// Get reminders list for current user
  Future<List<Reminder>> getReminders() async {
    try {
      final userPhone = await getCurrentUserPhone();
      if (userPhone == null) {
        _log('❌ Cannot load reminders: No user logged in');
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final key = _getRemindersKey(userPhone);
      final remindersString = prefs.getString(key);

      if (remindersString == null) {
        _log('No reminders found for user: $userPhone');
        return [];
      }

      final List<dynamic> remindersJson = jsonDecode(remindersString);
      final reminders = remindersJson
          .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
          .toList();

      _log('✅ Loaded ${reminders.length} reminders for user: $userPhone');
      return reminders;
    } catch (e) {
      _log('❌ Error loading reminders: $e');
      return [];
    }
  }

  // ============ INTAKE HISTORY MANAGEMENT ============

  /// Save intake histories list for current user
  Future<void> saveIntakeHistories(List<IntakeHistory> histories) async {
    try {
      final userPhone = await getCurrentUserPhone();
      if (userPhone == null) {
        _log('❌ Cannot save intake histories: No user logged in');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final historiesJson = histories.map((hist) => hist.toJson()).toList();
      final key = _getIntakeHistoriesKey(userPhone);
      await prefs.setString(key, jsonEncode(historiesJson));

      _log('✅ Saved ${histories.length} histories for user: $userPhone');
    } catch (e) {
      _log('❌ Error saving intake histories: $e');
      rethrow;
    }
  }

  /// Get intake histories list for current user
  Future<List<IntakeHistory>> getIntakeHistories() async {
    try {
      final userPhone = await getCurrentUserPhone();
      if (userPhone == null) {
        _log('❌ Cannot load intake histories: No user logged in');
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final key = _getIntakeHistoriesKey(userPhone);
      final historiesString = prefs.getString(key);

      if (historiesString == null) {
        _log('No histories found for user: $userPhone');
        return [];
      }

      final List<dynamic> historiesJson = jsonDecode(historiesString);
      final histories = historiesJson
          .map((json) => IntakeHistory.fromJson(json as Map<String, dynamic>))
          .toList();

      _log('✅ Loaded ${histories.length} histories for user: $userPhone');
      return histories;
    } catch (e) {
      _log('❌ Error loading intake histories: $e');
      return [];
    }
  }
}
