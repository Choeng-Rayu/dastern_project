import './generateId.dart';

class Patient {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String? address;
  final String tel;
  final String bloodtype;
  final String familyContact;
  final double? weight; // in kg

  Patient({
    String? id,
    required this.tel,
    required this.name,
    this.address,
    required this.bloodtype,
    required this.dateOfBirth,
    required this.familyContact,
    this.weight,
  }) : id = id ?? generateId.v4();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'address': address,
      'tel': tel,
      'bloodtype': bloodtype,
      'familyContact': familyContact,
      'weight': weight,
    };
  }

  // Create from JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      address: json['address'] as String?,
      tel: json['tel'] as String,
      bloodtype: json['bloodtype'] as String,
      familyContact: json['familyContact'] as String,
      weight:
          json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    );
  }

  // Copy with method for easy updates
  Patient copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    String? address,
    String? tel,
    String? bloodtype,
    String? familyContact,
    double? weight,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      tel: tel ?? this.tel,
      bloodtype: bloodtype ?? this.bloodtype,
      familyContact: familyContact ?? this.familyContact,
      weight: weight ?? this.weight,
    );
  }

  // Helper to get age
  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
