import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../donor/domain/entities/blood_request_entity.dart';
import '../repositories/hospital_repository.dart';

@lazySingleton
class GetAllPendingRequestsUseCase
    extends UseCase<List<BloodRequestEntity>, GetAllPendingRequestsParams> {
  final HospitalRepository _repository;

  GetAllPendingRequestsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BloodRequestEntity>>> call(
    GetAllPendingRequestsParams params,
  ) {
    return _repository.getAllPendingRequests(params.governate);
  }
}

class GetAllPendingRequestsParams extends Equatable {
  final String governate;

  const GetAllPendingRequestsParams({required this.governate});

  @override
  List<Object?> get props => [governate];
}
