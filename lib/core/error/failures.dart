import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Server failure (API errors, network issues)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache failure (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Validation failure (form validation errors)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Authentication failure (login, signup errors)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Network failure (no internet connection)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
