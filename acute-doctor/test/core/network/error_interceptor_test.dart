import 'package:acutework/core/errors/exceptions.dart';
import 'package:acutework/core/network/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ErrorInterceptor interceptor;

  setUp(() {
    interceptor = ErrorInterceptor();
  });

  DioException makeBadResponse(int statusCode, dynamic data) {
    final requestOptions = RequestOptions(path: '/test');
    return DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: statusCode,
        data: data,
      ),
    );
  }

  group('ErrorInterceptor.badResponse', () {
    test('uses detail field when message is absent', () {
      final err = makeBadResponse(400, {'detail': 'OTP expired'});

      final handler = CapturingHandler();
      interceptor.onError(err, handler);

      final rejected = handler.rejected!;
      expect(rejected.error, isA<ServerException>());
      final ex = rejected.error! as ServerException;
      expect(ex.message, 'OTP expired');
      expect(ex.code, '400');
    });

    test('message wins when both message and detail are present', () {
      final err = makeBadResponse(
        422,
        {'message': 'Validation failed', 'detail': 'OTP expired'},
      );

      final handler = CapturingHandler();
      interceptor.onError(err, handler);

      final rejected = handler.rejected!;
      expect(rejected.error, isA<ServerException>());
      final ex = rejected.error! as ServerException;
      expect(ex.message, 'Validation failed');
      expect(ex.code, '422');
    });

    test('falls back to generic message when neither field present', () {
      final err = makeBadResponse(500, {'error': 'boom'});

      final handler = CapturingHandler();
      interceptor.onError(err, handler);

      final ex = handler.rejected!.error! as ServerException;
      expect(ex.message, 'Server error (500)');
    });

    test('falls back to generic message when data is not a Map', () {
      final err = makeBadResponse(503, 'plain string body');

      final handler = CapturingHandler();
      interceptor.onError(err, handler);

      final ex = handler.rejected!.error! as ServerException;
      expect(ex.message, 'Server error (503)');
    });
  });
}

/// Minimal [ErrorInterceptorHandler] that records the rejected [DioException].
class CapturingHandler extends ErrorInterceptorHandler {
  DioException? rejected;

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    rejected = err;
  }
}
