import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/msg91_otp_service.dart';
import '../../data/otp_repository_impl.dart';
import '../../domain/otp_repository.dart';

final msg91OtpServiceProvider = Provider<Msg91OtpService>(
  (ref) => const Msg91OtpService(),
);

final _secureStorageProvider = Provider<SecureStorage>(
  (ref) => SecureStorage(const FlutterSecureStorage()),
);

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepositoryImpl(
    service: ref.watch(msg91OtpServiceProvider),
    secureStorage: ref.watch(_secureStorageProvider),
    config: AppConfig.I,
  );
});

/// UI-facing state for the OTP flow.
class AuthState {
  const AuthState({
    this.isSending = false,
    this.isVerifying = false,
    this.isResending = false,
    this.error,
    this.reqId,
    this.mobile,
    this.verifiedMobile,
  });

  final bool isSending;
  final bool isVerifying;
  final bool isResending;
  final String? error;

  /// MSG91 send-request id. Required for verify/resend.
  final String? reqId;

  /// Mobile number currently mid-flow.
  final String? mobile;

  /// Set once verifyOtp succeeds.
  final String? verifiedMobile;

  AuthState copyWith({
    bool? isSending,
    bool? isVerifying,
    bool? isResending,
    Object? error = _sentinel,
    Object? reqId = _sentinel,
    Object? mobile = _sentinel,
    Object? verifiedMobile = _sentinel,
  }) {
    return AuthState(
      isSending: isSending ?? this.isSending,
      isVerifying: isVerifying ?? this.isVerifying,
      isResending: isResending ?? this.isResending,
      error: identical(error, _sentinel) ? this.error : error as String?,
      reqId: identical(reqId, _sentinel) ? this.reqId : reqId as String?,
      mobile: identical(mobile, _sentinel) ? this.mobile : mobile as String?,
      verifiedMobile: identical(verifiedMobile, _sentinel)
          ? this.verifiedMobile
          : verifiedMobile as String?,
    );
  }

  static const _sentinel = Object();
}

class AuthController extends Notifier<AuthState> {
  late final OtpRepository _repo;

  @override
  AuthState build() {
    _repo = ref.watch(otpRepositoryProvider);
    return const AuthState();
  }

  Future<bool> sendOtp(String mobile) async {
    state = state.copyWith(isSending: true, error: null);
    final res = await _repo.sendOtp(mobile: mobile);
    return res.fold(
      (f) {
        state = state.copyWith(isSending: false, error: _message(f));
        return false;
      },
      (reqId) {
        state = state.copyWith(isSending: false, reqId: reqId, mobile: mobile);
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    final reqId = state.reqId;
    final mobile = state.mobile;
    if (reqId == null || mobile == null) {
      state = state.copyWith(error: 'Please request a new code');
      return false;
    }
    state = state.copyWith(isVerifying: true, error: null);
    final res = await _repo.verifyOtp(reqId: reqId, mobile: mobile, otp: otp);
    return res.fold(
      (f) {
        state = state.copyWith(isVerifying: false, error: _message(f));
        return false;
      },
      (_) {
        state = state.copyWith(isVerifying: false, verifiedMobile: mobile);
        return true;
      },
    );
  }

  Future<bool> resendOtp({bool voice = false}) async {
    final reqId = state.reqId;
    if (reqId == null) {
      state = state.copyWith(error: 'Please request a new code');
      return false;
    }
    state = state.copyWith(isResending: true, error: null);
    final res = await _repo.resendOtp(reqId: reqId, voice: voice);
    return res.fold(
      (f) {
        state = state.copyWith(isResending: false, error: _message(f));
        return false;
      },
      (_) {
        state = state.copyWith(isResending: false);
        return true;
      },
    );
  }

  void clearError() => state = state.copyWith(error: null);

  String _message(Failure f) => f.message;
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
