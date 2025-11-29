import '../../../donor/domain/entities/blood_request_entity.dart';
import '../../../../core/constants/enums.dart';

/// Hospital blood request model - reuses BloodRequestModel from donor feature
/// This model extends the existing model to include hospital-specific needs
class HospitalRequestModel {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final String patientName;
  final String bloodGroup;
  final String roomNumber;
  final String companionMobile;
  final String status;
  final String? acceptedBy;
  final String? acceptedDonorName;
  final String? acceptedDonorMobile;
  final String governate;
  final String city;
  final DateTime createdAt;
  final DateTime updatedAt;

  HospitalRequestModel({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.patientName,
    required this.bloodGroup,
    required this.roomNumber,
    required this.companionMobile,
    required this.status,
    this.acceptedBy,
    this.acceptedDonorName,
    this.acceptedDonorMobile,
    required this.governate,
    required this.city,
    required this.createdAt,
    required this.updatedAt,
  });

  /// From JSON
  factory HospitalRequestModel.fromJson(Map<String, dynamic> json) {
    // Extract donor info if joined
    String? donorName;
    String? donorMobile;
    if (json['donors'] != null) {
      final donor = json['donors'] as Map<String, dynamic>;
      donorName = donor['full_name'] as String?;
      donorMobile = donor['mobile'] as String?;
    }

    return HospitalRequestModel(
      id: json['id'] as String,
      hospitalId: json['hospital_id'] as String,
      hospitalName: json['hospital_name'] as String,
      patientName: json['patient_name'] as String,
      bloodGroup: json['blood_group'] as String,
      roomNumber: json['room_number'] as String,
      companionMobile: json['companion_mobile'] as String,
      status: json['status'] as String,
      acceptedBy: json['accepted_by'] as String?,
      acceptedDonorName: donorName,
      acceptedDonorMobile: donorMobile,
      governate: json['governate'] as String,
      city: json['city'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospital_id': hospitalId,
      'hospital_name': hospitalName,
      'patient_name': patientName,
      'blood_group': bloodGroup,
      'room_number': roomNumber,
      'companion_mobile': companionMobile,
      'status': status,
      'accepted_by': acceptedBy,
      'governate': governate,
      'city': city,
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
      patientName: patientName,
      bloodGroup: bloodGroup,
      roomNumber: roomNumber,
      companionMobile: companionMobile,
      status: RequestStatus.fromString(status),
      acceptedBy: acceptedBy,
      governate: governate,
      city: city,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// From Entity
  factory HospitalRequestModel.fromEntity(BloodRequestEntity entity) {
    return HospitalRequestModel(
      id: entity.id,
      hospitalId: entity.hospitalId,
      hospitalName: entity.hospitalName,
      patientName: entity.patientName,
      bloodGroup: entity.bloodGroup,
      roomNumber: entity.roomNumber ?? 'N/A',
      companionMobile: entity.companionMobile,
      status: entity.status.value,
      acceptedBy: entity.acceptedBy,
      governate: entity.governate,
      city: entity.city,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
