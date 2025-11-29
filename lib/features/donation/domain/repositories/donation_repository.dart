import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/donation.dart';

abstract class DonationRepository {
  /// Create a donation offer for a blood request
  Future<Either<Failure, Donation>> createDonationOffer({
    required String requestId,
    required String donorName,
    required String donorPhone,
    String? donorEmail,
  });

  /// Get all donations for a specific request (for hospital owner)
  Future<Either<Failure, List<Donation>>> getDonationsForRequest(
    String requestId,
  );

  /// Get my donation offers (for donor/hospital)
  Future<Either<Failure, List<Donation>>> getMyDonations();

  /// Accept a donation offer (by hospital owner)
  Future<Either<Failure, Donation>> acceptDonation(String donationId);

  /// Reject a donation offer (by hospital owner)
  Future<Either<Failure, Donation>> rejectDonation(String donationId);

  /// Verify OTP and complete donation
  Future<Either<Failure, bool>> verifyOtp({
    required String donationId,
    required String otpCode,
  });

  /// Get a single donation by ID
  Future<Either<Failure, Donation>> getDonationById(String donationId);
}
