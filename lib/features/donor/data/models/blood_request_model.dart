import '../../../../core/constants/enums.dart';
import '../../domain/entities/blood_request_entity.dart';

/// Blood Request model for API responses
class BloodRequestModel {
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

  const BloodRequestModel({
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

  /// From JSON (with hospital join)
  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id'] as String,
      hospitalId: json['hospital_id'] as String,
      hospitalName: json['hospitals']?['name'] as String? ?? 'Unknown Hospital',
      hospitalLocationLink: json['hospitals']?['address'] as String?,
      patientName: json['patient_name'] as String,
      bloodGroup: json['blood_group'] as String,
      roomNumber: json['room_number'] as String?,
      companionMobile: json['companion_mobile'] as String,
      status: RequestStatus.fromString(json['status'] as String),
      acceptedBy: json['accepted_by'] as String?,
      acceptedByName: json['donors']?['full_name'] as String?,
      governate: json['hospitals']?['governate'] as String? ?? '',
      city: json['hospitals']?['city'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospital_id': hospitalId,
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'room_number': roomNumber,
      'companion_mobile': companionMobile,
      'status': status.value,
      'accepted_by': acceptedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// To Entity
  BloodRequestEntity toEntity() {
    return BloodRequestEntity(
      id: id,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      hospitalLocationLink: hospitalLocationLink,
      patientName: patientName,
      bloodGroup: bloodGroup,
      roomNumber: roomNumber,
      companionMobile: companionMobile,
      status: status,
      acceptedBy: acceptedBy,
      acceptedByName: acceptedByName,
      governate: governate,
      city: city,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
