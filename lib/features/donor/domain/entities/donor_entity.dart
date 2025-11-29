import 'package:equatable/equatable.dart';
import '../../data/models/donor_model.dart';

/// Donor entity (domain layer)
class DonorEntity extends Equatable {
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

  const DonorEntity({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.mobile,
    required this.governate,
    required this.city,
    this.isAvailable = true,
    this.lastDonationDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    age,
    gender,
    bloodGroup,
    mobile,
    governate,
    city,
    isAvailable,
    lastDonationDate,
    createdAt,
  ];

  /// Copy with method for updates
  DonorEntity copyWith({
    String? fullName,
    int? age,
    String? gender,
    String? bloodGroup,
    String? mobile,
    String? governate,
    String? city,
    bool? isAvailable,
    DateTime? lastDonationDate,
  }) {
    return DonorEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      mobile: mobile ?? this.mobile,
      governate: governate ?? this.governate,
      city: city ?? this.city,
      isAvailable: isAvailable ?? this.isAvailable,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      createdAt: createdAt,
    );
  }

  /// Convert entity to model for data layer
  DonorModel toModel() {
    return DonorModel.fromEntity(this);
  }
}
