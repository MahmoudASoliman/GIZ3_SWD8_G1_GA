import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/blood_request_entity.dart';
import '../repositories/donor_repository.dart';

@lazySingleton
class GetRequestDetailsUseCase
    extends UseCase<BloodRequestEntity, GetRequestDetailsParams> {
  final DonorRepository _repository;

  GetRequestDetailsUseCase(this._repository);

  @override
  Future<Either<Failure, BloodRequestEntity>> call(
    GetRequestDetailsParams params,
  ) {
    return _repository.getRequestDetails(params.requestId);
  }
}

class GetRequestDetailsParams extends Equatable {
  final String requestId;

  const GetRequestDetailsParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}
