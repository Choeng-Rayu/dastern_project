import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/patient.dart';
import '../../models/medication.dart';

/// Provider to manage authentication state
class AuthProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  // ============ BYPASS ACCOUNT FOR DEVELOPMENT ============
  // This account allows quick login without registration
  static const String _bypassPhone = '012345678';
  static const String _bypassPassword = 'demo123';
  static final Patient _bypassPatient = Patient(
    name: 'Demo User',
    tel: _bypassPhone,
    familyContact: '0987654321',
    bloodtype: 'O+',
    dateOfBirth: DateTime(1990, 1, 1),
    address: 'Phnom Penh, Cambodia',
    weight: 70.0,
  );
  // ======================================================

  bool _isLoggedIn = false;
  Patient? _currentPatient;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  Patient? get currentPatient => _currentPatient;
  String? get userName => _currentPatient?.name;
  String? get userPhone => _currentPatient?.tel;
  bool get isLoading => _isLoading;

  void _log(String message) {
    debugPrint('👤 [AuthProvider] $message');
  }

  /// Initialize auth state from storage and create bypass account if needed
  Future<void> initialize() async {
    _log('Initializing auth state...');
    _isLoading = true;
    notifyListeners();

    // Ensure bypass account exists
    await _ensureBypassAccountExists();

    _isLoggedIn = await _storageService.isLoggedIn();

    if (_isLoggedIn) {
      _currentPatient = await _storageService.getPatientData();
      _log('✅ Auth initialized: User ${_currentPatient?.tel}');
    } else {
      _log('No user logged in');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ensure bypass/demo account exists for easy development login
  Future<void> _ensureBypassAccountExists() async {
    try {
      // Check if bypass account exists
      final exists = await _storageService.verifyCredentials(
        phone: _bypassPhone,
        password: _bypassPassword,
      );

      if (!exists) {
        // Create bypass account
        _log('🔧 Creating bypass account for development...');
        await _storageService.saveUserData(
          patient: _bypassPatient,
          password: _bypassPassword,
        );
        _log(
            '✅ Bypass account created (Phone: $_bypassPhone, Password: $_bypassPassword)');
      } else {
        _log('✓ Bypass account exists');
      }
    } catch (e) {
      _log('⚠️ Error ensuring bypass account: $e');
    }
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
      notifyListeners();
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
    notifyListeners();

    _log('✅ Registration successful: ${patient.tel}');
  }

  /// Logout
  Future<void> logout() async {
    _log('Logging out user: ${_currentPatient?.tel}');

    await _storageService.clearAuthData();
    _isLoggedIn = false;
    _currentPatient = null;
    notifyListeners();

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
      notifyListeners();
    }
  }
}
