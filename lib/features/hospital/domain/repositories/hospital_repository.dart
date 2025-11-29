import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/enums.dart';
import '../entities/hospital_entity.dart';
import '../../../donor/domain/entities/blood_request_entity.dart';

/// Repository interface for hospital operations
abstract class HospitalRepository {
  /// Create hospital profile
  Future<Either<Failure, HospitalEntity>> createProfile({
    required String userId,
    required String name,
    required String governate,
    required String city,
    required String address,
    required String mobile,
  });

  /// Get hospital profile by ID
  Future<Either<Failure, HospitalEntity>> getProfile(String hospitalId);

  /// Update hospital profile
  Future<Either<Failure, HospitalEntity>> updateProfile(
    HospitalEntity hospital,
  );

  /// Create blood request
  Future<Either<Failure, BloodRequestEntity>> createRequest({
    required String hospitalId,
    required String hospitalName,
    required String patientName,
    required String bloodGroup,
    required String roomNumber,
    required String companionMobile,
    required String governate,
    required String city,
  });

  /// Get all hospital requests
  Future<Either<Failure, List<BloodRequestEntity>>> getRequests(
    String hospitalId,
  );

  /// Get all pending requests in governate (for donation)
  Future<Either<Failure, List<BloodRequestEntity>>> getAllPendingRequests(
    String governate,
  );

  /// Update request status
  Future<Either<Failure, BloodRequestEntity>> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
  });

  /// Delete request
  Future<Either<Failure, void>> deleteRequest(String requestId);

  /// Get request details
  Future<Either<Failure, BloodRequestEntity>> getRequestDetails(
    String requestId,
  );
}
