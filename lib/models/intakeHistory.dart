// ignore: file_names
import './generateId.dart';

enum IntakeStatus { pending, missed, skipped, taken }

class IntakeHistory {
  final String id;
  final String medicationId;
  final String reminderId;
  final DateTime scheduledTime;
  final DateTime? takenAt;
  final IntakeStatus status;

  IntakeHistory({
    String? id,
    required this.medicationId,
    required this.reminderId,
    required this.scheduledTime,
    this.takenAt,
    required this.status,
  }) : id = id ?? generateId.v4();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'reminderId': reminderId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenAt': takenAt?.toIso8601String(),
      'status': status.name,
    };
  }

  // Create from JSON
  factory IntakeHistory.fromJson(Map<String, dynamic> json) {
    return IntakeHistory(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      reminderId: json['reminderId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenAt: json['takenAt'] != null
          ? DateTime.parse(json['takenAt'] as String)
          : null,
      status: IntakeStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }

  // Copy with method for easy updates
  IntakeHistory copyWith({
    String? id,
    String? medicationId,
    String? reminderId,
    DateTime? scheduledTime,
    DateTime? takenAt,
    IntakeStatus? status,
  }) {
    return IntakeHistory(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      reminderId: reminderId ?? this.reminderId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenAt: takenAt ?? this.takenAt,
      status: status ?? this.status,
    );
  }
}
