import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/hospital_repository.dart';

@lazySingleton
class DeleteRequestUseCase extends UseCase<void, DeleteRequestParams> {
  final HospitalRepository _repository;

  DeleteRequestUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteRequestParams params) {
    return _repository.deleteRequest(params.requestId);
  }
}

class DeleteRequestParams extends Equatable {
  final String requestId;

  const DeleteRequestParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}
