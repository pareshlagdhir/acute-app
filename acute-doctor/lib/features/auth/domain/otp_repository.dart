import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';

/// Contract for an OTP provider. Today fulfilled by MSG91's official Flutter
/// SDK; swap the implementation (e.g. for a backend proxy) without touching
/// callers when needed.
///
/// The MSG91 SDK returns a `reqId` from [sendOtp] which must be passed to
/// [verifyOtp] / [resendOtp]. Callers are expected to carry it across the
/// send→verify navigation (in Riverpod state).
abstract interface class OtpRepository {
  /// Sends an OTP to the given 10-digit national mobile number. The country
  /// code is prepended by the implementation (read from `AppConfig`).
  /// Returns the MSG91 `reqId` on success.
  Future<Either<Failure, String>> sendOtp({required String mobile});

  /// Verifies the user-entered OTP for the given send-request.
  /// On success returns the MSG91 access token for backend session exchange.
  Future<Either<Failure, String>> verifyOtp({
    required String reqId,
    required String mobile,
    required String otp,
  });

  /// Re-sends the OTP. [voice] = true requests the voice-call channel
  /// instead of SMS.
  Future<Either<Failure, Unit>> resendOtp({
    required String reqId,
    bool voice = false,
  });
}
