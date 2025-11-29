import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donor_entity.dart';
import '../repositories/donor_repository.dart';

@lazySingleton
class CreateProfileUseCase extends UseCase<DonorEntity, CreateProfileParams> {
  final DonorRepository _repository;

  CreateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, DonorEntity>> call(CreateProfileParams params) {
    return _repository.createProfile(
      userId: params.userId,
      fullName: params.fullName,
      age: params.age,
      gender: params.gender,
      bloodGroup: params.bloodGroup,
      mobile: params.mobile,
      governate: params.governate,
      city: params.city,
    );
  }
}

class CreateProfileParams extends Equatable {
  final String userId;
  final String fullName;
  final int age;
  final String gender;
  final String bloodGroup;
  final String mobile;
  final String governate;
  final String city;

  const CreateProfileParams({
    required this.userId,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.mobile,
    required this.governate,
    required this.city,
  });

  @override
  List<Object?> get props => [
    userId,
    fullName,
    age,
    gender,
    bloodGroup,
    mobile,
    governate,
    city,
  ];
}
