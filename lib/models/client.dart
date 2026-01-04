import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Client extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? location;

  @HiveField(3)
  String? contactPerson;

  @HiveField(4)
  String? contactPhone;

  @HiveField(5)
  String? contactEmail;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String? category; // For color-coding

  @HiveField(8)
  String? notes;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  String? projectName;

  Client({
    required this.id,
    required this.name,
    this.location,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    this.isActive = true,
    this.category,
    this.notes,
    this.projectName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy with method
  Client copyWith({
    String? id,
    String? name,
    String? location,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    bool? isActive,
    String? category,
    String? notes,
    String? projectName,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      projectName: projectName ?? this.projectName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'isActive': isActive,
      'category': category,
      'notes': notes,
      'projectName': projectName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // From JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      contactEmail: json['contactEmail'],
      isActive: json['isActive'] ?? true,
      category: json['category'],
      notes: json['notes'],
      projectName: json['projectName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
