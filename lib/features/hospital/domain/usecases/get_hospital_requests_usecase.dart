import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../donor/domain/entities/blood_request_entity.dart';
import '../repositories/hospital_repository.dart';

@lazySingleton
class GetHospitalRequestsUseCase extends UseCase<List<BloodRequestEntity>, GetHospitalRequestsParams> {
  final HospitalRepository _repository;

  GetHospitalRequestsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BloodRequestEntity>>> call(GetHospitalRequestsParams params) {
    return _repository.getRequests(params.hospitalId);
  }
}

class GetHospitalRequestsParams extends Equatable {
  final String hospitalId;

  const GetHospitalRequestsParams({required this.hospitalId});

  @override
  List<Object?> get props => [hospitalId];
}
