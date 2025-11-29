import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/blood_request_entity.dart';
import '../repositories/donor_repository.dart';

@lazySingleton
class GetRequestsUseCase
    extends UseCase<List<BloodRequestEntity>, GetRequestsParams> {
  final DonorRepository _repository;

  GetRequestsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BloodRequestEntity>>> call(
    GetRequestsParams params,
  ) {
    return _repository.getAvailableRequests(
      bloodGroup: params.bloodGroup,
      governate: params.governate,
    );
  }
}

class GetRequestsParams extends Equatable {
  final String bloodGroup;
  final String governate;

  const GetRequestsParams({required this.bloodGroup, required this.governate});

  @override
  List<Object?> get props => [bloodGroup, governate];
}
