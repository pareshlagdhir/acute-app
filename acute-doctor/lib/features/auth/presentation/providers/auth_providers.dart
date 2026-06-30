import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/otp_api.dart';
import '../../data/otp_repository_impl.dart';
import '../../domain/otp_repository.dart';
import '../../../onboarding/data/models/login_models.dart';

final otpApiProvider = Provider<OtpApi>(
  (ref) => OtpApi(ref.watch(dioProvider)),
);

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepositoryImpl(
    api: ref.watch(otpApiProvider),
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
    this.mobile,
    this.verifiedMobile,
    this.onboardingNeeded = false,
  });

  final bool isSending;
  final bool isVerifying;
  final bool isResending;
  final String? error;

  /// Mobile number currently mid-flow.
  final String? mobile;

  /// Set once verifyOtp succeeds.
  final String? verifiedMobile;

  /// True when the backend signals the doctor profile is incomplete.
  final bool onboardingNeeded;

  AuthState copyWith({
    bool? isSending,
    bool? isVerifying,
    bool? isResending,
    Object? error = _sentinel,
    Object? mobile = _sentinel,
    Object? verifiedMobile = _sentinel,
    bool? onboardingNeeded,
  }) {
    return AuthState(
      isSending: isSending ?? this.isSending,
      isVerifying: isVerifying ?? this.isVerifying,
      isResending: isResending ?? this.isResending,
      error: identical(error, _sentinel) ? this.error : error as String?,
      mobile: identical(mobile, _sentinel) ? this.mobile : mobile as String?,
      verifiedMobile: identical(verifiedMobile, _sentinel)
          ? this.verifiedMobile
          : verifiedMobile as String?,
      onboardingNeeded: onboardingNeeded ?? this.onboardingNeeded,
    );
  }

  static const _sentinel = Object();
}

class AuthController extends Notifier<AuthState> {
  late final OtpRepository _repo;
  late final SecureStorage _storage;

  @override
  AuthState build() {
    _repo = ref.watch(otpRepositoryProvider);
    _storage = ref.watch(secureStorageProvider);
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
      (_) {
        state = state.copyWith(isSending: false, mobile: mobile);
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    final mobile = state.mobile;
    if (mobile == null) {
      state = state.copyWith(error: 'Please request a new code');
      return false;
    }
    state = state.copyWith(isVerifying: true, error: null);
    final res = await _repo.verifyOtp(mobile: mobile, otp: otp);
    final resp = res.fold<LoginResponse?>(
      (f) {
        state = state.copyWith(isVerifying: false, error: _message(f));
        return null;
      },
      (r) => r,
    );
    if (resp == null) return false;
    await _storage.writeAuthToken(resp.token);
    ref.read(authTokenProvider.notifier).token = resp.token;
    state = state.copyWith(
      isVerifying: false,
      verifiedMobile: mobile,
      onboardingNeeded: resp.onboardingNeeded,
    );
    return true;
  }

  Future<bool> resendOtp({bool voice = false}) async {
    final mobile = state.mobile;
    if (mobile == null) {
      state = state.copyWith(error: 'Please request a new code');
      return false;
    }
    state = state.copyWith(isResending: true, error: null);
    final res = await _repo.resendOtp(mobile: mobile, voice: voice);
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

  /// Clears the persisted session and in-memory token, returning the app to
  /// an unauthenticated state. The router redirect then guards protected
  /// routes back to login.
  Future<void> logout() async {
    await _storage.clear();
    ref.read(authTokenProvider.notifier).token = null;
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);

  String _message(Failure f) => f.message;
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
