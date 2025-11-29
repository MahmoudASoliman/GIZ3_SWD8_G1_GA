import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/constants/enums.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../../../donor/domain/entities/blood_request_entity.dart';
import '../datasources/hospital_remote_datasource.dart';

@LazySingleton(as: HospitalRepository)
class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalRemoteDataSource _remoteDataSource;

  HospitalRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, HospitalEntity>> createProfile({
    required String userId,
    required String name,
    required String governate,
    required String city,
    required String address,
    required String mobile,
  }) async {
    try {
      final model = await _remoteDataSource.createProfile(
        userId: userId,
        name: name,
        governate: governate,
        city: city,
        address: address,
        mobile: mobile,
      );
      return Right(model.toEntity());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, HospitalEntity>> getProfile(String hospitalId) async {
    try {
      final model = await _remoteDataSource.getProfile(hospitalId);
      return Right(model.toEntity());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, HospitalEntity>> updateProfile(
    HospitalEntity hospital,
  ) async {
    try {
      final model = await _remoteDataSource.updateProfile(hospital.toModel());
      return Right(model.toEntity());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BloodRequestEntity>> createRequest({
    required String hospitalId,
    required String hospitalName,
    required String patientName,
    required String bloodGroup,
    required String roomNumber,
    required String companionMobile,
    required String governate,
    required String city,
  }) async {
    try {
      final model = await _remoteDataSource.createRequest(
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        patientName: patientName,
        bloodGroup: bloodGroup,
        roomNumber: roomNumber,
        companionMobile: companionMobile,
        governate: governate,
        city: city,
      );
      return Right(model.toEntity());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BloodRequestEntity>>> getRequests(
    String hospitalId,
  ) async {
    try {
      final models = await _remoteDataSource.getRequests(hospitalId);
      return Right(models.map((model) => model.toEntity()).toList());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BloodRequestEntity>>> getAllPendingRequests(
    String governate,
  ) async {
    try {
      final models = await _remoteDataSource.getAllPendingRequests(governate);
      return Right(models.map((model) => model.toEntity()).toList());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BloodRequestEntity>> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    try {
      final model = await _remoteDataSource.updateRequestStatus(
        requestId: requestId,
        status: status,
      );
      return Right(model.toEntity());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRequest(String requestId) async {
    try {
      await _remoteDataSource.deleteRequest(requestId);
      return const Right(null);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BloodRequestEntity>> getRequestDetails(
    String requestId,
  ) async {
    try {
      final model = await _remoteDataSource.getRequestDetails(requestId);
      return Right(model.toEntity());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
