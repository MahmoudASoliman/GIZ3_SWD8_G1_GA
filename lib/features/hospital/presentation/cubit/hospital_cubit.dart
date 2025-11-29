import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../../domain/usecases/create_hospital_profile_usecase.dart';
import '../../domain/usecases/get_hospital_profile_usecase.dart';
import '../../domain/usecases/create_blood_request_usecase.dart';
import '../../domain/usecases/get_hospital_requests_usecase.dart';
import '../../domain/usecases/get_all_pending_requests_usecase.dart';
import '../../domain/usecases/update_request_status_usecase.dart';
import '../../domain/usecases/delete_request_usecase.dart';
import 'hospital_state.dart';

@injectable
class HospitalCubit extends Cubit<HospitalState> {
  final CreateHospitalProfileUseCase _createProfileUseCase;
  final GetHospitalProfileUseCase _getProfileUseCase;
  final CreateBloodRequestUseCase _createRequestUseCase;
  final GetHospitalRequestsUseCase _getRequestsUseCase;
  final GetAllPendingRequestsUseCase _getAllPendingRequestsUseCase;
  final UpdateRequestStatusUseCase _updateStatusUseCase;
  final DeleteRequestUseCase _deleteRequestUseCase;
  final HospitalRepository _repository;

  // Store profile for later use
  HospitalEntity? _cachedProfile;
  HospitalEntity? get profile => _cachedProfile;

  HospitalCubit(
    this._createProfileUseCase,
    this._getProfileUseCase,
    this._createRequestUseCase,
    this._getRequestsUseCase,
    this._getAllPendingRequestsUseCase,
    this._updateStatusUseCase,
    this._deleteRequestUseCase,
    this._repository,
  ) : super(const HospitalInitial());

  /// Create hospital profile
  Future<void> createProfile({
    required String userId,
    required String name,
    required String governate,
    required String city,
    required String address,
    required String mobile,
  }) async {
    emit(const HospitalLoading());

    final result = await _createProfileUseCase(
      CreateHospitalProfileParams(
        userId: userId,
        name: name,
        governate: governate,
        city: city,
        address: address,
        mobile: mobile,
      ),
    );

    result.fold((failure) => emit(HospitalError(failure.message)), (profile) {
      _cachedProfile = profile;
      emit(HospitalProfileCreated(profile, 'Profile created successfully!'));
    });
  }

  /// Get hospital profile
  Future<void> loadProfile(String hospitalId) async {
    emit(const HospitalLoading());

    final result = await _getProfileUseCase(
      GetHospitalProfileParams(hospitalId: hospitalId),
    );

    result.fold((failure) => emit(HospitalError(failure.message)), (profile) {
      _cachedProfile = profile;
      emit(HospitalProfileLoaded(profile));
    });
  }

  /// Create blood request
  Future<void> createRequest({
    required String hospitalId,
    required String hospitalName,
    required String patientName,
    required String bloodGroup,
    required String roomNumber,
    required String companionMobile,
    required String governate,
    required String city,
  }) async {
    emit(const HospitalLoading());

    final result = await _createRequestUseCase(
      CreateBloodRequestParams(
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        patientName: patientName,
        bloodGroup: bloodGroup,
        roomNumber: roomNumber,
        companionMobile: companionMobile,
        governate: governate,
        city: city,
      ),
    );

    result.fold(
      (failure) => emit(HospitalError(failure.message)),
      (request) => emit(
        HospitalRequestCreated(request, 'Blood request created successfully!'),
      ),
    );
  }

  /// Get hospital requests
  Future<void> loadRequests(String hospitalId) async {
    emit(const HospitalLoading());

    final result = await _getRequestsUseCase(
      GetHospitalRequestsParams(hospitalId: hospitalId),
    );

    result.fold(
      (failure) => emit(HospitalError(failure.message)),
      (requests) => emit(HospitalRequestsLoaded(requests)),
    );
  }

  /// Reload requests using cached profile
  Future<void> reloadRequests() async {
    if (_cachedProfile != null) {
      await loadRequests(_cachedProfile!.id);
    }
  }

  /// Load all pending requests in governate (for hospital to donate)
  Future<void> loadAllPendingRequests(String governate) async {
    emit(const HospitalLoading());

    final result = await _getAllPendingRequestsUseCase(
      GetAllPendingRequestsParams(governate: governate),
    );

    result.fold(
      (failure) {
        emit(HospitalError(failure.message));
      },
      (requests) {
        emit(HospitalAllPendingRequestsLoaded(requests));
      },
    );
  }

  /// Reload all pending requests using cached profile
  Future<void> reloadAllPendingRequests() async {
    if (_cachedProfile != null) {
      await loadAllPendingRequests(_cachedProfile!.governate);
    }
  }

  /// Update request status
  Future<void> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    emit(const HospitalLoading());

    final result = await _updateStatusUseCase(
      UpdateRequestStatusParams(requestId: requestId, status: status),
    );

    result.fold(
      (failure) => emit(HospitalError(failure.message)),
      (request) => emit(
        HospitalRequestStatusUpdated(request, 'Request status updated!'),
      ),
    );
  }

  /// Delete request
  Future<void> deleteRequest(String requestId) async {
    emit(const HospitalLoading());

    final result = await _deleteRequestUseCase(
      DeleteRequestParams(requestId: requestId),
    );

    result.fold(
      (failure) => emit(HospitalError(failure.message)),
      (_) =>
          emit(const HospitalRequestDeleted('Request deleted successfully!')),
    );
  }

  /// Load single request details by ID
  Future<void> loadRequestDetails(String requestId) async {
    emit(const HospitalLoading());

    final result = await _repository.getRequestDetails(requestId);

    result.fold(
      (failure) {
        emit(HospitalError(failure.message));
      },
      (request) {
        emit(HospitalRequestDetailsLoaded(request));
      },
    );
  }

  /// Reset to initial state
  void reset() {
    _cachedProfile = null;
    emit(const HospitalInitial());
  }
}
