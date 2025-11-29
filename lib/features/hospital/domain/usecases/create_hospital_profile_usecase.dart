import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/hospital_entity.dart';
import '../repositories/hospital_repository.dart';

@lazySingleton
class CreateHospitalProfileUseCase extends UseCase<HospitalEntity, CreateHospitalProfileParams> {
  final HospitalRepository _repository;

  CreateHospitalProfileUseCase(this._repository);

  @override
  Future<Either<Failure, HospitalEntity>> call(CreateHospitalProfileParams params) {
    return _repository.createProfile(
      userId: params.userId,
      name: params.name,
      governate: params.governate,
      city: params.city,
      address: params.address,
      mobile: params.mobile,
    );
  }
}

class CreateHospitalProfileParams extends Equatable {
  final String userId;
  final String name;
  final String governate;
  final String city;
  final String address;
  final String mobile;

  const CreateHospitalProfileParams({
    required this.userId,
    required this.name,
    required this.governate,
    required this.city,
    required this.address,
    required this.mobile,
  });

  @override
  List<Object?> get props => [userId, name, governate, city, address, mobile];
}
