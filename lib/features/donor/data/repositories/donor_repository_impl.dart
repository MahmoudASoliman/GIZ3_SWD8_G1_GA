import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../domain/entities/donor_entity.dart';
import '../../domain/entities/blood_request_entity.dart';
import '../../domain/repositories/donor_repository.dart';
import '../datasources/donor_remote_datasource.dart';

@LazySingleton(as: DonorRepository)
class DonorRepositoryImpl implements DonorRepository {
  final DonorRemoteDataSource _remoteDataSource;

  DonorRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, DonorEntity>> createProfile({
    required String userId,
    required String fullName,
    required int age,
    required String gender,
    required String bloodGroup,
    required String mobile,
    required String governate,
    required String city,
  }) async {
    try {
      final model = await _remoteDataSource.createProfile(
        userId: userId,
        fullName: fullName,
        age: age,
        gender: gender,
        bloodGroup: bloodGroup,
        mobile: mobile,
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
  Future<Either<Failure, DonorEntity>> getProfile(String donorId) async {
    try {
      final model = await _remoteDataSource.getProfile(donorId);
      return Right(model.toEntity());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DonorEntity>> updateProfile(DonorEntity donor) async {
    try {
      final model = await _remoteDataSource.updateProfile(donor.toModel());
      return Right(model.toEntity());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BloodRequestEntity>>> getAvailableRequests({
    required String bloodGroup,
    required String governate,
  }) async {
    try {
      final models = await _remoteDataSource.getAvailableRequests(
        bloodGroup: bloodGroup,
        governate: governate,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BloodRequestEntity>> acceptRequest({
    required String requestId,
    required String donorId,
  }) async {
    try {
      final model = await _remoteDataSource.acceptRequest(
        requestId: requestId,
        donorId: donorId,
      );
      return Right(model.toEntity());
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
