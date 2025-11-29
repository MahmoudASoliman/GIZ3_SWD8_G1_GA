import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/donation.dart';
import '../../domain/repositories/donation_repository.dart';
import '../datasources/donation_remote_datasource.dart';

@Injectable(as: DonationRepository)
class DonationRepositoryImpl implements DonationRepository {
  final DonationRemoteDataSource _remoteDataSource;

  DonationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Donation>> createDonationOffer({
    required String requestId,
    required String donorName,
    required String donorPhone,
    String? donorEmail,
  }) async {
    try {
      final result = await _remoteDataSource.createDonationOffer(
        requestId: requestId,
        donorName: donorName,
        donorPhone: donorPhone,
        donorEmail: donorEmail,
      );

      // Result is now the full donation row from the database
      if (result.containsKey('id')) {
        final donation = await _remoteDataSource.getDonationById(
          result['id'] as String,
        );
        return Right(donation);
      } else if (result['success'] == true) {
        // Old format from RPC function
        final donation = await _remoteDataSource.getDonationById(
          result['donation_id'] as String,
        );
        return Right(donation);
      } else {
        return Left(
          ServerFailure(
            result['message'] as String? ?? 'Failed to create donation',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Donation>>> getDonationsForRequest(
    String requestId,
  ) async {
    try {
      final donations = await _remoteDataSource.getDonationsForRequest(
        requestId,
      );
      return Right(donations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Donation>>> getMyDonations() async {
    try {
      final donations = await _remoteDataSource.getMyDonations();
      return Right(donations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Donation>> acceptDonation(String donationId) async {
    try {
      final donation = await _remoteDataSource.updateDonationStatus(
        donationId,
        'accepted',
      );
      return Right(donation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Donation>> rejectDonation(String donationId) async {
    try {
      final donation = await _remoteDataSource.updateDonationStatus(
        donationId,
        'rejected',
      );
      return Right(donation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String donationId,
    required String otpCode,
  }) async {
    try {
      final result = await _remoteDataSource.verifyOtp(donationId, otpCode);

      if (result['success'] == true) {
        return const Right(true);
      } else {
        return Left(
          ServerFailure(result['message'] as String? ?? 'Invalid OTP'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Donation>> getDonationById(String donationId) async {
    try {
      final donation = await _remoteDataSource.getDonationById(donationId);
      return Right(donation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
