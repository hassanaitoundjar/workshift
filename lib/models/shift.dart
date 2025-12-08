import 'package:hive/hive.dart';

part 'shift.g.dart';

@HiveType(typeId: 2)
enum ShiftType {
  @HiveField(0)
  morning, // 4 hours

  @HiveField(1)
  allDay, // 8 hours

  @HiveField(2)
  afternoon, // 4 hours

  @HiveField(3)
  off, // 0 hours
}

@HiveType(typeId: 3)
class Shift extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String employeeId;

  @HiveField(2)
  String? clientId;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  ShiftType shiftType;

  @HiveField(5)
  double advanceMoney; // Money given in advance for this shift

  @HiveField(6)
  String? notes;

  @HiveField(7)
  bool isConfirmed;

  @HiveField(8)
  DateTime createdAt;

  Shift({
    required this.id,
    required this.employeeId,
    this.clientId,
    required this.date,
    required this.shiftType,
    this.advanceMoney = 0.0,
    this.notes,
    this.isConfirmed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Get duration in hours based on shift type
  double get durationInHours {
    switch (shiftType) {
      case ShiftType.morning:
        return 4.0;
      case ShiftType.allDay:
        return 8.0;
      case ShiftType.afternoon:
        return 4.0;
      case ShiftType.off:
        return 0.0;
    }
  }

  // Get shift type display name
  String get shiftTypeName {
    switch (shiftType) {
      case ShiftType.morning:
        return 'Morning (4h)';
      case ShiftType.allDay:
        return 'All Day (8h)';
      case ShiftType.afternoon:
        return 'Afternoon (4h)';
      case ShiftType.off:
        return 'Off';
    }
  }

  // Copy with method
  Shift copyWith({
    String? id,
    String? employeeId,
    String? clientId,
    DateTime? date,
    ShiftType? shiftType,
    double? advanceMoney,
    String? notes,
    bool? isConfirmed,
    DateTime? createdAt,
  }) {
    return Shift(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      shiftType: shiftType ?? this.shiftType,
      advanceMoney: advanceMoney ?? this.advanceMoney,
      notes: notes ?? this.notes,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'clientId': clientId,
      'date': date.toIso8601String(),
      'shiftType': shiftType.index,
      'advanceMoney': advanceMoney,
      'notes': notes,
      'isConfirmed': isConfirmed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // From JSON
  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      employeeId: json['employeeId'],
      clientId: json['clientId'],
      date: DateTime.parse(json['date']),
      shiftType: ShiftType.values[json['shiftType']],
      advanceMoney: (json['advanceMoney'] ?? 0.0).toDouble(),
      notes: json['notes'],
      isConfirmed: json['isConfirmed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
