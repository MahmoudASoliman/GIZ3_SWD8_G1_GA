import '../../domain/entities/donor_entity.dart';

/// Donor model for API responses
class DonorModel {
  final String id;
  final String fullName;
  final int age;
  final String gender;
  final String bloodGroup;
  final String mobile;
  final String governate;
  final String city;
  final bool isAvailable;
  final DateTime? lastDonationDate;
  final DateTime createdAt;

  const DonorModel({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.mobile,
    required this.governate,
    required this.city,
    required this.isAvailable,
    this.lastDonationDate,
    required this.createdAt,
  });

  /// From JSON
  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      // Use user_id as the main id for the app (links to auth.users)
      id: json['user_id'] as String,
      fullName: json['full_name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      bloodGroup: json['blood_group'] as String,
      mobile: json['mobile'] as String,
      governate: json['governate'] as String,
      city: json['city'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      lastDonationDate: json['last_donation_date'] != null
          ? DateTime.parse(json['last_donation_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'blood_group': bloodGroup,
      'mobile': mobile,
      'governate': governate,
      'city': city,
      'is_available': isAvailable,
      'last_donation_date': lastDonationDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// To Entity
  DonorEntity toEntity() {
    return DonorEntity(
      id: id,
      fullName: fullName,
      age: age,
      gender: gender,
      bloodGroup: bloodGroup,
      mobile: mobile,
      governate: governate,
      city: city,
      isAvailable: isAvailable,
      lastDonationDate: lastDonationDate,
      createdAt: createdAt,
    );
  }

  /// From Entity
  factory DonorModel.fromEntity(DonorEntity entity) {
    return DonorModel(
      id: entity.id,
      fullName: entity.fullName,
      age: entity.age,
      gender: entity.gender,
      bloodGroup: entity.bloodGroup,
      mobile: entity.mobile,
      governate: entity.governate,
      city: entity.city,
      isAvailable: entity.isAvailable,
      lastDonationDate: entity.lastDonationDate,
      createdAt: entity.createdAt,
    );
  }
}
