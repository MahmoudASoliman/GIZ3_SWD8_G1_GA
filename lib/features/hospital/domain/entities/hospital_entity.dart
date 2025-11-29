import 'package:equatable/equatable.dart';
import '../../data/models/hospital_model.dart';

/// Hospital entity (domain layer)
class HospitalEntity extends Equatable {
  final String id; // The actual hospital table id (for foreign keys)
  final String userId; // The auth user id
  final String name;
  final String governate;
  final String city;
  final String address;
  final String mobile;
  final DateTime createdAt;

  const HospitalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.governate,
    required this.city,
    required this.address,
    required this.mobile,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    governate,
    city,
    address,
    mobile,
    createdAt,
  ];

  /// Copy with method for updates
  HospitalEntity copyWith({
    String? name,
    String? governate,
    String? city,
    String? address,
    String? mobile,
  }) {
    return HospitalEntity(
      id: id,
      userId: userId,
      name: name ?? this.name,
      governate: governate ?? this.governate,
      city: city ?? this.city,
      address: address ?? this.address,
      mobile: mobile ?? this.mobile,
      createdAt: createdAt,
    );
  }

  /// Convert entity to model for data layer
  HospitalModel toModel() {
    return HospitalModel.fromEntity(this);
  }
}
