import 'package:equatable/equatable.dart';

enum DonationStatus {
  pending,
  accepted,
  rejected,
  completed,
  expired;

  static DonationStatus fromString(String status) {
    switch (status) {
      case 'pending':
        return DonationStatus.pending;
      case 'accepted':
        return DonationStatus.accepted;
      case 'rejected':
        return DonationStatus.rejected;
      case 'completed':
        return DonationStatus.completed;
      case 'expired':
        return DonationStatus.expired;
      default:
        return DonationStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case DonationStatus.pending:
        return 'pending';
      case DonationStatus.accepted:
        return 'accepted';
      case DonationStatus.rejected:
        return 'rejected';
      case DonationStatus.completed:
        return 'completed';
      case DonationStatus.expired:
        return 'expired';
    }
  }
}

class Donation extends Equatable {
  final String id;
  final String requestId;
  final String donorUserId;
  final String donorType; // 'donor' or 'hospital'
  final String otpCode;
  final DateTime otpExpiresAt;
  final DonationStatus status;
  final String donorName;
  final String donorPhone;
  final String? donorEmail;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Donation({
    required this.id,
    required this.requestId,
    required this.donorUserId,
    required this.donorType,
    required this.otpCode,
    required this.otpExpiresAt,
    required this.status,
    required this.donorName,
    required this.donorPhone,
    this.donorEmail,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if OTP is expired
  bool get isOtpExpired => DateTime.now().isAfter(otpExpiresAt);

  /// Get remaining time for OTP
  Duration get remainingTime {
    final remaining = otpExpiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Format remaining time as HH:MM:SS
  String get remainingTimeFormatted {
    final remaining = remainingTime;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Donation copyWith({
    String? id,
    String? requestId,
    String? donorUserId,
    String? donorType,
    String? otpCode,
    DateTime? otpExpiresAt,
    DonationStatus? status,
    String? donorName,
    String? donorPhone,
    String? donorEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Donation(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      donorUserId: donorUserId ?? this.donorUserId,
      donorType: donorType ?? this.donorType,
      otpCode: otpCode ?? this.otpCode,
      otpExpiresAt: otpExpiresAt ?? this.otpExpiresAt,
      status: status ?? this.status,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
      donorEmail: donorEmail ?? this.donorEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    requestId,
    donorUserId,
    donorType,
    otpCode,
    otpExpiresAt,
    status,
    donorName,
    donorPhone,
    donorEmail,
    createdAt,
    updatedAt,
  ];
}
