import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

/// Provider to manage authentication state
class AuthProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isLoggedIn = false;
  String? _userName;
  String? _userPhone;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  bool get isLoading => _isLoading;

  /// Initialize auth state from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await _storageService.isLoggedIn();

    if (_isLoggedIn) {
      _userName = await _storageService.getUserName();
      _userPhone = await _storageService.getUserPhone();
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
      _userName = await _storageService.getUserName();
      _userPhone = phone;
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Register new user
  Future<void> register({
    required String phone,
    required String password,
    required String name,
  }) async {
    await _storageService.saveAuthData(
      phone: phone,
      password: password,
      name: name,
    );

    _isLoggedIn = true;
    _userName = name;
    _userPhone = phone;
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await _storageService.clearAuthData();
    _isLoggedIn = false;
    _userName = null;
    _userPhone = null;
    notifyListeners();
  }
}
