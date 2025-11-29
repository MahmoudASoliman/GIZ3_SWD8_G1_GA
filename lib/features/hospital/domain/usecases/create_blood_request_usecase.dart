import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../donor/domain/entities/blood_request_entity.dart';
import '../repositories/hospital_repository.dart';

@lazySingleton
class CreateBloodRequestUseCase extends UseCase<BloodRequestEntity, CreateBloodRequestParams> {
  final HospitalRepository _repository;

  CreateBloodRequestUseCase(this._repository);

  @override
  Future<Either<Failure, BloodRequestEntity>> call(CreateBloodRequestParams params) {
    return _repository.createRequest(
      hospitalId: params.hospitalId,
      hospitalName: params.hospitalName,
      patientName: params.patientName,
      bloodGroup: params.bloodGroup,
      roomNumber: params.roomNumber,
      companionMobile: params.companionMobile,
      governate: params.governate,
      city: params.city,
    );
  }
}

class CreateBloodRequestParams extends Equatable {
  final String hospitalId;
  final String hospitalName;
  final String patientName;
  final String bloodGroup;
  final String roomNumber;
  final String companionMobile;
  final String governate;
  final String city;

  const CreateBloodRequestParams({
    required this.hospitalId,
    required this.hospitalName,
    required this.patientName,
    required this.bloodGroup,
    required this.roomNumber,
    required this.companionMobile,
    required this.governate,
    required this.city,
  });

  @override
  List<Object?> get props => [
        hospitalId,
        hospitalName,
        patientName,
        bloodGroup,
        roomNumber,
        companionMobile,
        governate,
        city,
      ];
}
