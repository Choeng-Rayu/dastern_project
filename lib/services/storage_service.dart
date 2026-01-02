import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle local storage operations for user data and authentication
class StorageService {
  static const String _authKey = 'user_auth';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Save user authentication data
  Future<void> saveAuthData({
    required String phone,
    required String password,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final authData = {
      'phone': phone,
      'password': password,
      'name': name,
      'loginTime': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_authKey, jsonEncode(authData));
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Get stored authentication data
  Future<Map<String, dynamic>?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final authDataString = prefs.getString(_authKey);

    if (authDataString == null) {
      return null;
    }

    return jsonDecode(authDataString) as Map<String, dynamic>;
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
    final authData = await getAuthData();

    if (authData == null) {
      return false;
    }

    return authData['phone'] == phone && authData['password'] == password;
  }

  /// Clear authentication data (logout)
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Get logged in user's name
  Future<String?> getUserName() async {
    final authData = await getAuthData();
    return authData?['name'] as String?;
  }

  /// Get logged in user's phone
  Future<String?> getUserPhone() async {
    final authData = await getAuthData();
    return authData?['phone'] as String?;
  }
}
