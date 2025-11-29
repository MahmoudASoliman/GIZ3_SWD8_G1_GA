import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donor_entity.dart';
import '../repositories/donor_repository.dart';

@lazySingleton
class UpdateProfileUseCase extends UseCase<DonorEntity, UpdateProfileParams> {
  final DonorRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, DonorEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(params.donor);
  }
}

class UpdateProfileParams extends Equatable {
  final DonorEntity donor;

  const UpdateProfileParams({required this.donor});

  @override
  List<Object?> get props => [donor];
}
