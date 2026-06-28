/// Throwable counterparts to `Failure` — emitted at the data layer.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code});
  final String message;
  final String? code;
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}
