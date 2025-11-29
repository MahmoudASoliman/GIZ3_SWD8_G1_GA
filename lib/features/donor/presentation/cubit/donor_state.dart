import 'package:equatable/equatable.dart';
import '../../domain/entities/donor_entity.dart';
import '../../domain/entities/blood_request_entity.dart';

/// Base state for donor feature
abstract class DonorState extends Equatable {
  const DonorState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DonorInitial extends DonorState {
  const DonorInitial();
}

/// Loading state
class DonorLoading extends DonorState {
  const DonorLoading();
}

/// Profile loaded successfully
class DonorProfileLoaded extends DonorState {
  final DonorEntity profile;

  const DonorProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Requests loaded successfully
class DonorRequestsLoaded extends DonorState {
  final List<BloodRequestEntity> requests;

  const DonorRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// Request details loaded
class DonorRequestDetailsLoaded extends DonorState {
  final BloodRequestEntity request;

  const DonorRequestDetailsLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

/// Request accepted successfully
class DonorRequestAccepted extends DonorState {
  final BloodRequestEntity request;
  final String message;

  const DonorRequestAccepted(this.request, this.message);

  @override
  List<Object?> get props => [request, message];
}

/// Profile updated successfully
class DonorProfileUpdated extends DonorState {
  final DonorEntity profile;
  final String message;

  const DonorProfileUpdated(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

/// Profile created successfully
class DonorProfileCreated extends DonorState {
  final DonorEntity profile;
  final String message;

  const DonorProfileCreated(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

/// Error state
class DonorError extends DonorState {
  final String message;

  const DonorError(this.message);

  @override
  List<Object?> get props => [message];
}
