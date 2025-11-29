import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/get_requests_usecase.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/get_request_details_usecase.dart';
import '../../domain/entities/donor_entity.dart';
import 'donor_state.dart';

@injectable
class DonorCubit extends Cubit<DonorState> {
  final CreateProfileUseCase _createProfileUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetRequestsUseCase _getRequestsUseCase;
  final AcceptRequestUseCase _acceptRequestUseCase;
  final GetRequestDetailsUseCase _getRequestDetailsUseCase;

  // Store profile for later use
  DonorEntity? _cachedProfile;
  DonorEntity? get profile => _cachedProfile;

  DonorCubit(
    this._createProfileUseCase,
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._getRequestsUseCase,
    this._acceptRequestUseCase,
    this._getRequestDetailsUseCase,
  ) : super(const DonorInitial());

  /// Create donor profile
  Future<void> createProfile({
    required String userId,
    required String fullName,
    required int age,
    required String gender,
    required String bloodGroup,
    required String mobile,
    required String governate,
    required String city,
  }) async {
    emit(const DonorLoading());

    final result = await _createProfileUseCase(
      CreateProfileParams(
        userId: userId,
        fullName: fullName,
        age: age,
        gender: gender,
        bloodGroup: bloodGroup,
        mobile: mobile,
        governate: governate,
        city: city,
      ),
    );

    result.fold((failure) => emit(DonorError(failure.message)), (profile) {
      _cachedProfile = profile;
      emit(DonorProfileCreated(profile, 'Profile created successfully!'));
    });
  }

  /// Get donor profile
  Future<void> loadProfile(String donorId) async {
    emit(const DonorLoading());

    final result = await _getProfileUseCase(GetProfileParams(donorId: donorId));

    result.fold(
      (failure) {
        emit(DonorError(failure.message));
      },
      (profile) {
        _cachedProfile = profile;
        emit(DonorProfileLoaded(profile));
      },
    );
  }

  /// Update donor profile
  Future<void> updateProfile(DonorEntity donor) async {
    emit(const DonorLoading());

    final result = await _updateProfileUseCase(
      UpdateProfileParams(donor: donor),
    );

    result.fold((failure) => emit(DonorError(failure.message)), (profile) {
      _cachedProfile = profile;
      emit(DonorProfileUpdated(profile, 'Profile updated successfully!'));
    });
  }

  /// Get available blood requests
  Future<void> loadRequests({
    required String bloodGroup,
    required String governate,
  }) async {
    emit(const DonorLoading());

    final result = await _getRequestsUseCase(
      GetRequestsParams(bloodGroup: bloodGroup, governate: governate),
    );

    result.fold(
      (failure) => emit(DonorError(failure.message)),
      (requests) => emit(DonorRequestsLoaded(requests)),
    );
  }

  /// Reload requests using cached profile
  Future<void> reloadRequests() async {
    if (_cachedProfile != null) {
      await loadRequests(
        bloodGroup: _cachedProfile!.bloodGroup,
        governate: _cachedProfile!.governate,
      );
    }
  }

  /// Accept blood request
  Future<void> acceptRequest({
    required String requestId,
    required String donorId,
  }) async {
    emit(const DonorLoading());

    final result = await _acceptRequestUseCase(
      AcceptRequestParams(requestId: requestId, donorId: donorId),
    );

    result.fold(
      (failure) => emit(DonorError(failure.message)),
      (request) =>
          emit(DonorRequestAccepted(request, 'Request accepted successfully!')),
    );
  }

  /// Get request details
  Future<void> loadRequestDetails(String requestId) async {
    emit(const DonorLoading());

    final result = await _getRequestDetailsUseCase(
      GetRequestDetailsParams(requestId: requestId),
    );

    result.fold(
      (failure) => emit(DonorError(failure.message)),
      (request) => emit(DonorRequestDetailsLoaded(request)),
    );
  }

  /// Reset to initial state
  void reset() {
    _cachedProfile = null;
    emit(const DonorInitial());
  }
}
