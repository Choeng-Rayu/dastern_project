/// {@template unit_enum}
/// [Unit] is an enumeration that defines the possible measurement units
/// for medication dosages.
///
/// The [Unit] enum is closely related to the [Dosage] class, which contains
/// an [amount] (String) and a [unit] (int) field. The [unit] field in [Dosage]
/// should correspond to one of the [Unit] enum values (ml, mg, or other) to
/// specify what type of measurement unit the dosage amount represents.
///
/// [Medication] objects contain a [Dosage] object, which in turn uses [Unit]
/// to define the measurement unit for the prescribed dosage. This creates a
/// hierarchical relationship: Medication -> Dosage -> Unit, allowing for
/// complete specification of how a medication should be dosed.
///
/// Values:
/// * [Unit.tablet] - Tablets/pills
/// * [Unit.ml] - Milliliters (volume measurement)
/// * [Unit.mg] - Milligrams (mass/weight measurement)
/// * [Unit.other] - Other non-standard measurement units
/// {@endtemplate}
import 'package:flutter/material.dart';
import './generateId.dart';

enum Unit { tablet, ml, mg, other }

class Dosage {
  final double amount;
  final Unit unit;

  const Dosage({
    required this.amount,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'unit': unit.name,
    };
  }

  factory Dosage.fromJson(Map<String, dynamic> json) {
    return Dosage(
      amount: (json['amount'] as num).toDouble(),
      unit: Unit.values.firstWhere((e) => e.name == json['unit']),
    );
  }

  @override
  String toString() {
    return '$amount ${unit.name}';
  }
}

class Medication {
  final String id;
  final String name;
  final Dosage dosage;
  final String instruction;
  final String prescribeBy;
  final Color? color; // For UI display
  final IconData? icon; // For UI display

  Medication({
    String? id,
    required this.dosage,
    required this.name,
    required this.instruction,
    required this.prescribeBy,
    this.color,
    this.icon,
  }) : id = id ?? generateId.v4();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage.toJson(),
      'instruction': instruction,
      'prescribeBy': prescribeBy,
      'color': color?.value,
      'icon': icon?.codePoint,
    };
  }

  // Create from JSON
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: Dosage.fromJson(json['dosage'] as Map<String, dynamic>),
      instruction: json['instruction'] as String,
      prescribeBy: json['prescribeBy'] as String,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      icon: json['icon'] != null
          ? IconData(json['icon'] as int, fontFamily: 'MaterialIcons')
          : null,
    );
  }

  // Copy with method for easy updates
  Medication copyWith({
    String? id,
    String? name,
    Dosage? dosage,
    String? instruction,
    String? prescribeBy,
    Color? color,
    IconData? icon,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instruction: instruction ?? this.instruction,
      prescribeBy: prescribeBy ?? this.prescribeBy,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
