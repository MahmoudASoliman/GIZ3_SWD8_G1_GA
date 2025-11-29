/// Base class for all exceptions
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Server exception (API errors)
class ServerException extends AppException {
  ServerException(super.message, [super.statusCode]);
}

/// Cache exception (local storage errors)
class CacheException extends AppException {
  CacheException(super.message);
}

/// Network exception (no internet)
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Authentication exception
class AuthException extends AppException {
  AuthException(super.message, [super.statusCode]);
}

/// Validation exception
class ValidationException extends AppException {
  ValidationException(super.message);
}
