import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  double pricePerDay;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  DateTime createdAt;

  Employee({
    required this.id,
    required this.name,
    this.phone,
    this.pricePerDay = 0.0,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy with method
  Employee copyWith({
    String? id,
    String? name,
    String? phone,
    double? pricePerDay,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'pricePerDay': pricePerDay,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // From JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      pricePerDay: (json['pricePerDay'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
