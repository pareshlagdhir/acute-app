import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

/// Maps Dio errors to typed `AppException`s consumable by repositories.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        const NetworkException(),
      DioExceptionType.badResponse => ServerException(
          (err.response?.data is Map &&
                  (err.response?.data as Map)['message'] is String)
              ? (err.response?.data as Map)['message'] as String
              : 'Server error (${err.response?.statusCode})',
          code: err.response?.statusCode?.toString(),
        ),
      DioExceptionType.cancel => const ServerException('Request cancelled'),
      DioExceptionType.badCertificate => const NetworkException('Bad certificate'),
      DioExceptionType.unknown => const NetworkException(),
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }
}
