import '../../domain/entities/hospital_entity.dart';

/// Hospital model (data layer)
class HospitalModel {
  final String id; // The actual hospital table id (for foreign keys)
  final String userId; // The auth user id
  final String name;
  final String governate;
  final String city;
  final String address;
  final String mobile;
  final DateTime createdAt;

  HospitalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.governate,
    required this.city,
    required this.address,
    required this.mobile,
    required this.createdAt,
  });

  /// From JSON
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String, // The actual hospital table id
      userId: json['user_id'] as String, // The auth user id
      name: json['name'] as String,
      governate: json['governate'] as String,
      city: json['city'] as String,
      address: json['address'] as String? ?? '',
      mobile:
          json['mobile'] as String? ?? json['phone_number'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'governate': governate,
      'city': city,
      'address': address,
      'mobile': mobile,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// From Entity
  factory HospitalModel.fromEntity(HospitalEntity entity) {
    return HospitalModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      governate: entity.governate,
      city: entity.city,
      address: entity.address,
      mobile: entity.mobile,
      createdAt: entity.createdAt,
    );
  }

  /// To Entity
  HospitalEntity toEntity() {
    return HospitalEntity(
      id: id,
      userId: userId,
      name: name,
      governate: governate,
      city: city,
      address: address,
      mobile: mobile,
      createdAt: createdAt,
    );
  }
}
