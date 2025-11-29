import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donor_entity.dart';
import '../repositories/donor_repository.dart';

@lazySingleton
class GetProfileUseCase extends UseCase<DonorEntity, GetProfileParams> {
  final DonorRepository _repository;

  GetProfileUseCase(this._repository);

  @override
  Future<Either<Failure, DonorEntity>> call(GetProfileParams params) {
    return _repository.getProfile(params.donorId);
  }
}

class GetProfileParams extends Equatable {
  final String donorId;

  const GetProfileParams({required this.donorId});

  @override
  List<Object?> get props => [donorId];
}
