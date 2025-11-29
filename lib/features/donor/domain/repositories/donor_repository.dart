import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/donor_entity.dart';
import '../entities/blood_request_entity.dart';

/// Repository interface for donor operations
abstract class DonorRepository {
  /// Create donor profile
  Future<Either<Failure, DonorEntity>> createProfile({
    required String userId,
    required String fullName,
    required int age,
    required String gender,
    required String bloodGroup,
    required String mobile,
    required String governate,
    required String city,
  });

  /// Get donor profile by ID
  Future<Either<Failure, DonorEntity>> getProfile(String donorId);

  /// Update donor profile
  Future<Either<Failure, DonorEntity>> updateProfile(DonorEntity donor);

  /// Get available blood requests for donor
  Future<Either<Failure, List<BloodRequestEntity>>> getAvailableRequests({
    required String bloodGroup,
    required String governate,
  });

  /// Accept a blood request
  Future<Either<Failure, BloodRequestEntity>> acceptRequest({
    required String requestId,
    required String donorId,
  });

  /// Get blood request details
  Future<Either<Failure, BloodRequestEntity>> getRequestDetails(
    String requestId,
  );
}
