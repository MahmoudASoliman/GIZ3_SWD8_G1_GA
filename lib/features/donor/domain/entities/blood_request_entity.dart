import 'package:equatable/equatable.dart';
import '../../../../core/constants/enums.dart';

/// Blood Request entity (domain layer)
class BloodRequestEntity extends Equatable {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final String? hospitalLocationLink;
  final String patientName;
  final String bloodGroup;
  final String? roomNumber;
  final String companionMobile;
  final RequestStatus status;
  final String? acceptedBy;
  final String? acceptedByName;
  final String governate;
  final String city;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BloodRequestEntity({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    this.hospitalLocationLink,
    required this.patientName,
    required this.bloodGroup,
    this.roomNumber,
    required this.companionMobile,
    required this.status,
    this.acceptedBy,
    this.acceptedByName,
    required this.governate,
    required this.city,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    hospitalId,
    hospitalName,
    hospitalLocationLink,
    patientName,
    bloodGroup,
    roomNumber,
    companionMobile,
    status,
    acceptedBy,
    acceptedByName,
    governate,
    city,
    createdAt,
    updatedAt,
  ];

  /// Copy with method
  BloodRequestEntity copyWith({
    RequestStatus? status,
    String? acceptedBy,
    String? acceptedByName,
    DateTime? updatedAt,
  }) {
    return BloodRequestEntity(
      id: id,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      patientName: patientName,
      bloodGroup: bloodGroup,
      roomNumber: roomNumber,
      companionMobile: companionMobile,
      status: status ?? this.status,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedByName: acceptedByName ?? this.acceptedByName,
      governate: governate,
      city: city,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
