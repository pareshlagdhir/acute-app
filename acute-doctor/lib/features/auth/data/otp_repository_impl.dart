import 'package:dartz/dartz.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../onboarding/data/models/login_models.dart';
import '../domain/otp_repository.dart';
import 'models/otp_models.dart';
import 'otp_api.dart';

class OtpRepositoryImpl implements OtpRepository {
  OtpRepositoryImpl({required OtpApi api, required AppConfig config})
      : _api = api,
        _config = config;

  final OtpApi _api;
  final AppConfig _config;

  @override
  Future<Either<Failure, Unit>> sendOtp({required String mobile}) =>
      _guard(() async {
        await _api.sendOtp(OtpSendRequest(mobile: _fullMobile(mobile)));
        return unit;
      });

  @override
  Future<Either<Failure, LoginResponse>> verifyOtp({
    required String mobile,
    required String otp,
  }) =>
      _guard(() => _api.verifyOtp(
            OtpVerifyRequest(mobile: _fullMobile(mobile), otp: otp),
          ),);

  @override
  Future<Either<Failure, Unit>> resendOtp({
    required String mobile,
    bool voice = false,
  }) =>
      _guard(() async {
        await _api.resendOtp(
          OtpResendRequest(mobile: _fullMobile(mobile), voice: voice),
        );
        return unit;
      });

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
