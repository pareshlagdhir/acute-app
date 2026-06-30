import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:acutework/core/config/app_config.dart';
import 'package:acutework/core/errors/exceptions.dart';
import 'package:acutework/core/errors/failures.dart';
import 'package:acutework/features/auth/data/models/otp_models.dart';
import 'package:acutework/features/auth/data/otp_api.dart';
import 'package:acutework/features/auth/data/otp_repository_impl.dart';
import 'package:acutework/features/onboarding/data/models/login_models.dart';

class _FakeOtpApi implements OtpApi {
  OtpVerifyRequest? lastVerify;
  OtpSendRequest? lastSend;
  OtpResendRequest? lastResend;
  Exception? error;

  @override
  Future<void> sendOtp(OtpSendRequest body) async {
    lastSend = body;
    if (error != null) throw error!;
  }

  @override
  Future<LoginResponse> verifyOtp(OtpVerifyRequest body) async {
    lastVerify = body;
    if (error != null) throw error!;
    return const LoginResponse(
      token: 't',
      isNew: true,
      onboardingNeeded: true,
      profileCompletion: 0,
    );
  }

  @override
  Future<void> resendOtp(OtpResendRequest body) async {
    lastResend = body;
    if (error != null) throw error!;
  }
}

void main() {
  late _FakeOtpApi api;
  late OtpRepositoryImpl repo;

  setUp(() {
    AppConfig.init(
      flavor: Flavor.dev,
      appName: 'test',
      apiBaseUrl: 'http://localhost:8000',
      defaultCountryCode: '91',
    );
    api = _FakeOtpApi();
    repo = OtpRepositoryImpl(api: api, config: AppConfig.I);
  });

  test('sendOtp prepends country code and returns Unit', () async {
    final res = await repo.sendOtp(mobile: '9876543210');
    expect(res, isA<Right<Failure, Unit>>());
    expect(api.lastSend!.mobile, '919876543210');
  });

  test('verifyOtp returns LoginResponse on success', () async {
    final res = await repo.verifyOtp(mobile: '9876543210', otp: '1234');
    expect(res.isRight(), true);
    expect(api.lastVerify!.mobile, '919876543210');
  });

  test('maps ServerException to ServerFailure', () async {
    api.error = const ServerException('bad otp', code: 'error');
    final res = await repo.verifyOtp(mobile: '9876543210', otp: '0000');
    expect(res.isLeft(), true);
    res.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('resendOtp prepends country code', () async {
    final res = await repo.resendOtp(mobile: '9876543210');
    expect(res.isRight(), true);
    expect(api.lastResend!.mobile, '919876543210');
  });

  test('maps NetworkException to NetworkFailure', () async {
    api.error = const NetworkException('offline');
    final res = await repo.sendOtp(mobile: '9876543210');
    expect(res.isLeft(), true);
    res.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('maps unexpected exception to UnknownFailure', () async {
    api.error = const FormatException('boom');
    final res = await repo.sendOtp(mobile: '9876543210');
    expect(res.isLeft(), true);
    res.fold(
      (f) => expect(f, isA<UnknownFailure>()),
      (_) => fail('expected Left'),
    );
  });
}
