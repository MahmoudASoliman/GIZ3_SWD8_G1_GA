import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/enums.dart';
import '../entities/user_entity.dart';

/// Auth repository interface (domain layer contract)
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required UserType userType,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<bool> isLoggedIn();
}
