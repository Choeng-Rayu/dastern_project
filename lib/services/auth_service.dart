import 'package:flutter/material.dart';
import 'storage_service.dart';
import '../models/patient.dart';

/// Service to manage authentication state
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storageService = StorageService();

  bool _isLoggedIn = false;
  Patient? _currentPatient;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  Patient? get currentPatient => _currentPatient;
  String? get userName => _currentPatient?.name;
  String? get userPhone => _currentPatient?.tel;
  bool get isLoading => _isLoading;

  void _log(String message) {
    debugPrint('👤 [AuthService] $message');
  }

  /// Initialize auth state from storage
  Future<void> initialize() async {
    _log('Initializing auth state...');
    _isLoading = true;

    _isLoggedIn = await _storageService.isLoggedIn();

    if (_isLoggedIn) {
      _currentPatient = await _storageService.getPatientData();
      _log('✅ Auth initialized: User ${_currentPatient?.tel}');
    } else {
      _log('No user logged in');
    }

    _isLoading = false;
  }

  /// Login with credentials
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _log('Attempting login for phone: $phone');

    // Verify credentials
    final isValid = await _storageService.verifyCredentials(
      phone: phone,
      password: password,
    );

    if (isValid) {
      _isLoggedIn = true;
      _currentPatient = await _storageService.getPatientData();
      _log('✅ Login successful for: ${_currentPatient?.tel}');
      return true;
    }

    _log('❌ Login failed: Invalid credentials');
    return false;
  }

  /// Register new user with complete patient data
  Future<void> register({
    required Patient patient,
    required String password,
  }) async {
    _log('Registering new user: ${patient.tel}');

    await _storageService.saveUserData(
      patient: patient,
      password: password,
    );

    _isLoggedIn = true;
    _currentPatient = patient;

    _log('✅ Registration successful: ${patient.tel}');
  }

  /// Logout
  Future<void> logout() async {
    _log('Logging out user: ${_currentPatient?.tel}');

    await _storageService.clearAuthData();
    _isLoggedIn = false;
    _currentPatient = null;

    _log('✅ Logout successful');
  }

  /// Update patient data
  Future<void> updatePatient(Patient patient) async {
    final password = await _storageService.getPassword();
    if (password != null) {
      await _storageService.saveUserData(
        patient: patient,
        password: password,
      );
      _currentPatient = patient;
    }
  }
}
