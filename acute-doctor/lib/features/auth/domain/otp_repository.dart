import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../onboarding/data/models/login_models.dart';

/// Contract for the backend OTP flow. The backend (MSG91Service) owns
/// send/verify/resend; the app talks only to our API. `mobile` is the
/// 10-digit national number — the implementation prepends the country code.
abstract interface class OtpRepository {
  /// Sends an OTP to the given national mobile number.
  Future<Either<Failure, Unit>> sendOtp({required String mobile});

  /// Verifies the OTP. On success the backend issues the session, returned
  /// here as a [LoginResponse] (token + onboarding flags).
  Future<Either<Failure, LoginResponse>> verifyOtp({
    required String mobile,
    required String otp,
  });

  /// Re-sends the OTP. [voice] = true requests the voice channel instead of SMS.
  Future<Either<Failure, Unit>> resendOtp({
    required String mobile,
    bool voice = false,
  });
}
