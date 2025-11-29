import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/constants/enums.dart';
import '../../../donor/domain/entities/blood_request_entity.dart';
import '../repositories/hospital_repository.dart';

@lazySingleton
class UpdateRequestStatusUseCase extends UseCase<BloodRequestEntity, UpdateRequestStatusParams> {
  final HospitalRepository _repository;

  UpdateRequestStatusUseCase(this._repository);

  @override
  Future<Either<Failure, BloodRequestEntity>> call(UpdateRequestStatusParams params) {
    return _repository.updateRequestStatus(
      requestId: params.requestId,
      status: params.status,
    );
  }
}

class UpdateRequestStatusParams extends Equatable {
  final String requestId;
  final RequestStatus status;

  const UpdateRequestStatusParams({
    required this.requestId,
    required this.status,
  });

  @override
  List<Object?> get props => [requestId, status];
}
