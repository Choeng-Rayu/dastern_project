import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../models/medication.dart';

/// Provider to manage medications with CRUD operations
class MedicationProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Medication> _medications = [];
  bool _isLoading = true;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  /// Initialize medications from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _medications = await _storageService.getMedications();

    _isLoading = false;
    notifyListeners();
  }

  /// Get medication by ID
  Medication? getMedicationById(String id) {
    try {
      return _medications.firstWhere((med) => med.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new medication
  Future<Medication> addMedication(Medication medication) async {
    _medications.add(medication);
    await _storageService.saveMedications(_medications);
    notifyListeners();
    return medication;
  }

  /// Update existing medication
  Future<void> updateMedication(Medication medication) async {
    final index = _medications.indexWhere((med) => med.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
      await _storageService.saveMedications(_medications);
      notifyListeners();
    }
  }

  /// Delete medication
  Future<void> deleteMedication(String medicationId) async {
    _medications.removeWhere((med) => med.id == medicationId);
    await _storageService.saveMedications(_medications);
    notifyListeners();
  }

  /// Clear all medications
  Future<void> clearAllMedications() async {
    _medications.clear();
    await _storageService.saveMedications(_medications);
    notifyListeners();
  }
}
