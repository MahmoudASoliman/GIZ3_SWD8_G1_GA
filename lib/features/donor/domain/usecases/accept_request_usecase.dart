import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/blood_request_entity.dart';
import '../repositories/donor_repository.dart';

@lazySingleton
class AcceptRequestUseCase
    extends UseCase<BloodRequestEntity, AcceptRequestParams> {
  final DonorRepository _repository;

  AcceptRequestUseCase(this._repository);

  @override
  Future<Either<Failure, BloodRequestEntity>> call(AcceptRequestParams params) {
    return _repository.acceptRequest(
      requestId: params.requestId,
      donorId: params.donorId,
    );
  }
}

class AcceptRequestParams extends Equatable {
  final String requestId;
  final String donorId;

  const AcceptRequestParams({required this.requestId, required this.donorId});

  @override
  List<Object?> get props => [requestId, donorId];
}
