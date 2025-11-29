import 'package:equatable/equatable.dart';
import '../../domain/entities/donation.dart';

abstract class DonationState extends Equatable {
  const DonationState();

  @override
  List<Object?> get props => [];
}

class DonationInitial extends DonationState {
  const DonationInitial();
}

class DonationLoading extends DonationState {
  const DonationLoading();
}

class DonationOfferCreated extends DonationState {
  final Donation donation;

  const DonationOfferCreated(this.donation);

  @override
  List<Object?> get props => [donation];
}

class DonationsLoaded extends DonationState {
  final List<Donation> donations;

  const DonationsLoaded(this.donations);

  @override
  List<Object?> get props => [donations];
}

class DonationUpdated extends DonationState {
  final Donation donation;
  final String message;

  const DonationUpdated(this.donation, this.message);

  @override
  List<Object?> get props => [donation, message];
}

class OtpVerified extends DonationState {
  final String message;

  const OtpVerified(this.message);

  @override
  List<Object?> get props => [message];
}

class DonationError extends DonationState {
  final String message;

  const DonationError(this.message);

  @override
  List<Object?> get props => [message];
}
