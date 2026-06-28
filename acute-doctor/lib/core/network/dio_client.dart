import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({required String? Function() tokenProvider}) {
    final cfg = AppConfig.I;
    final dio = Dio(
      BaseOptions(
        baseUrl: cfg.apiBaseUrl,
        connectTimeout: Duration(milliseconds: cfg.apiTimeoutMs),
        receiveTimeout: Duration(milliseconds: cfg.apiTimeoutMs),
        sendTimeout: Duration(milliseconds: cfg.apiTimeoutMs),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(tokenProvider: tokenProvider),
      ErrorInterceptor(),
      if (cfg.enableLogging)
        PrettyDioLogger(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          compact: true,
        ),
    ]);

    return dio;
  }
}
