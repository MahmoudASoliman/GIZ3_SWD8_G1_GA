import '../entities/donation.dart';

class DonationModel extends Donation {
  const DonationModel({
    required super.id,
    required super.requestId,
    required super.donorUserId,
    required super.donorType,
    required super.otpCode,
    required super.otpExpiresAt,
    required super.status,
    required super.donorName,
    required super.donorPhone,
    super.donorEmail,
    required super.createdAt,
    super.updatedAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      donorUserId: json['donor_user_id'] as String,
      donorType: json['donor_type'] as String,
      otpCode: json['otp_code'] as String,
      otpExpiresAt: DateTime.parse(json['otp_expires_at'] as String),
      status: DonationStatus.fromString(json['status'] as String),
      donorName: json['donor_name'] as String,
      donorPhone: json['donor_phone'] as String,
      donorEmail: json['donor_email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'donor_user_id': donorUserId,
      'donor_type': donorType,
      'otp_code': otpCode,
      'otp_expires_at': otpExpiresAt.toIso8601String(),
      'status': status.value,
      'donor_name': donorName,
      'donor_phone': donorPhone,
      'donor_email': donorEmail,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from function result (create_donation_offer)
  factory DonationModel.fromFunctionResult(Map<String, dynamic> json) {
    return DonationModel(
      id: json['donation_id'] as String,
      requestId: '', // Will be filled later
      donorUserId: '', // Will be filled later
      donorType: '',
      otpCode: json['otp_code'] as String,
      otpExpiresAt: DateTime.now().add(const Duration(hours: 24)),
      status: DonationStatus.pending,
      donorName: '',
      donorPhone: '',
      createdAt: DateTime.now(),
    );
  }
}
