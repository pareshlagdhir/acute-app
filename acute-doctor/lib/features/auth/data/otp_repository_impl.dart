import 'package:dartz/dartz.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../domain/otp_repository.dart';
import 'msg91_otp_service.dart';

class OtpRepositoryImpl implements OtpRepository {
  OtpRepositoryImpl({
    required Msg91OtpService service,
    required AppConfig config,
  })  : _service = service,
        _config = config;

  final Msg91OtpService _service;
  final AppConfig _config;

  @override
  Future<Either<Failure, String>> sendOtp({required String mobile}) async {
    return _guard(() => _service.sendOtp(identifier: _fullMobile(mobile)));
  }

  @override
  Future<Either<Failure, String>> verifyOtp({
    required String reqId,
    required String mobile,
    required String otp,
  }) async {
    return _guard(() async {
      final accessToken = await _service.verifyOtp(reqId: reqId, otp: otp);
      return accessToken;
    });
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({
    required String reqId,
    bool voice = false,
  }) async {
    return _guard(() async {
      await _service.resendOtp(reqId: reqId, channel: voice ? 4 : 11);
      return unit;
    });
  }

  String _fullMobile(String national) => '${_config.defaultCountryCode}$national';

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on Object catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
