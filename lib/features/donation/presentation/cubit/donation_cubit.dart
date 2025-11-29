import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/repositories/donation_repository.dart';
import 'donation_state.dart';

@injectable
class DonationCubit extends Cubit<DonationState> {
  final DonationRepository _donationRepository;

  DonationCubit(this._donationRepository) : super(const DonationInitial());

  /// Create a donation offer for a blood request
  Future<void> createDonationOffer({
    required String requestId,
    required String donorName,
    required String donorPhone,
    String? donorEmail,
  }) async {
    emit(const DonationLoading());

    final result = await _donationRepository.createDonationOffer(
      requestId: requestId,
      donorName: donorName,
      donorPhone: donorPhone,
      donorEmail: donorEmail,
    );

    result.fold(
      (failure) {
        emit(DonationError(failure.message));
      },
      (donation) {
        emit(DonationOfferCreated(donation));
      },
    );
  }

  /// Get all donations for a specific request
  Future<void> getDonationsForRequest(String requestId) async {
    emit(const DonationLoading());

    final result = await _donationRepository.getDonationsForRequest(requestId);

    result.fold(
      (failure) {
        emit(DonationError(failure.message));
      },
      (donations) {
        emit(DonationsLoaded(donations));
      },
    );
  }

  /// Get my donation offers
  Future<void> getMyDonations() async {
    emit(const DonationLoading());

    final result = await _donationRepository.getMyDonations();

    result.fold(
      (failure) => emit(DonationError(failure.message)),
      (donations) => emit(DonationsLoaded(donations)),
    );
  }

  /// Accept a donation offer
  Future<void> acceptDonation(String donationId) async {
    emit(const DonationLoading());

    final result = await _donationRepository.acceptDonation(donationId);

    result.fold(
      (failure) => emit(DonationError(failure.message)),
      (donation) =>
          emit(DonationUpdated(donation, AppStrings.donationAccepted)),
    );
  }

  /// Reject a donation offer
  Future<void> rejectDonation(String donationId) async {
    emit(const DonationLoading());

    final result = await _donationRepository.rejectDonation(donationId);

    result.fold(
      (failure) => emit(DonationError(failure.message)),
      (donation) =>
          emit(DonationUpdated(donation, AppStrings.donationRejected)),
    );
  }

  /// Verify OTP and complete donation
  Future<void> verifyOtp({
    required String donationId,
    required String otpCode,
  }) async {
    emit(const DonationLoading());

    final result = await _donationRepository.verifyOtp(
      donationId: donationId,
      otpCode: otpCode,
    );

    result.fold(
      (failure) {
        emit(DonationError(failure.message));
      },
      (success) {
        emit(OtpVerified(AppStrings.donationCompleted));
      },
    );
  }
}
