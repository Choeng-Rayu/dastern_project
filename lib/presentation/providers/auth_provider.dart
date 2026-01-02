import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/patient.dart';

/// Provider to manage authentication state
class AuthProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isLoggedIn = false;
  Patient? _currentPatient;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  Patient? get currentPatient => _currentPatient;
  String? get userName => _currentPatient?.name;
  String? get userPhone => _currentPatient?.tel;
  bool get isLoading => _isLoading;

  /// Initialize auth state from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await _storageService.isLoggedIn();

    if (_isLoggedIn) {
      _currentPatient = await _storageService.getPatientData();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login with credentials
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    // Verify credentials
    final isValid = await _storageService.verifyCredentials(
      phone: phone,
      password: password,
    );

    if (isValid) {
      _isLoggedIn = true;
      _currentPatient = await _storageService.getPatientData();
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Register new user with complete patient data
  Future<void> register({
    required Patient patient,
    required String password,
  }) async {
    await _storageService.saveUserData(
      patient: patient,
      password: password,
    );

    _isLoggedIn = true;
    _currentPatient = patient;
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await _storageService.clearAuthData();
    _isLoggedIn = false;
    _currentPatient = null;
    notifyListeners();
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
      notifyListeners();
    }
  }
}
