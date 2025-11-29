import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/hospital_entity.dart';
import '../repositories/hospital_repository.dart';

@lazySingleton
class GetHospitalProfileUseCase extends UseCase<HospitalEntity, GetHospitalProfileParams> {
  final HospitalRepository _repository;

  GetHospitalProfileUseCase(this._repository);

  @override
  Future<Either<Failure, HospitalEntity>> call(GetHospitalProfileParams params) {
    return _repository.getProfile(params.hospitalId);
  }
}

class GetHospitalProfileParams extends Equatable {
  final String hospitalId;

  const GetHospitalProfileParams({required this.hospitalId});

  @override
  List<Object?> get props => [hospitalId];
}
