import 'package:equatable/equatable.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../../donor/domain/entities/blood_request_entity.dart';

/// Base state for hospital feature
abstract class HospitalState extends Equatable {
  const HospitalState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HospitalInitial extends HospitalState {
  const HospitalInitial();
}

/// Loading state
class HospitalLoading extends HospitalState {
  const HospitalLoading();
}

/// Profile loaded successfully
class HospitalProfileLoaded extends HospitalState {
  final HospitalEntity profile;

  const HospitalProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Requests loaded successfully
class HospitalRequestsLoaded extends HospitalState {
  final List<BloodRequestEntity> requests;

  const HospitalRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// All pending requests loaded (for donation)
class HospitalAllPendingRequestsLoaded extends HospitalState {
  final List<BloodRequestEntity> requests;

  const HospitalAllPendingRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// Request details loaded
class HospitalRequestDetailsLoaded extends HospitalState {
  final BloodRequestEntity request;

  const HospitalRequestDetailsLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

/// Request created successfully
class HospitalRequestCreated extends HospitalState {
  final BloodRequestEntity request;
  final String message;

  const HospitalRequestCreated(this.request, this.message);

  @override
  List<Object?> get props => [request, message];
}

/// Request status updated
class HospitalRequestStatusUpdated extends HospitalState {
  final BloodRequestEntity request;
  final String message;

  const HospitalRequestStatusUpdated(this.request, this.message);

  @override
  List<Object?> get props => [request, message];
}

/// Request deleted successfully
class HospitalRequestDeleted extends HospitalState {
  final String message;

  const HospitalRequestDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

/// Profile created successfully
class HospitalProfileCreated extends HospitalState {
  final HospitalEntity profile;
  final String message;

  const HospitalProfileCreated(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

/// Error state
class HospitalError extends HospitalState {
  final String message;

  const HospitalError(this.message);

  @override
  List<Object?> get props => [message];
}
