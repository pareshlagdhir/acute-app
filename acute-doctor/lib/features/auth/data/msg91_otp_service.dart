import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

import '../../../core/errors/exceptions.dart';

/// Thin wrapper over `sendotp_flutter_sdk`'s `OTPWidget` static methods.
///
/// The SDK returns a `Map<dynamic, dynamic>` shaped roughly like:
///   { "type": "success" | "error", "message": "...", "reqId": "..." }
/// or surfaces errors with a non-success `type`. We normalise both into Dart
/// exceptions the repository can map to `Failure`s.
class Msg91OtpService {
  const Msg91OtpService();

  /// Sends an OTP to [identifier] (mobile with country code, or email).
  /// Returns the `reqId` that must be quoted on verify/retry.
  Future<String> sendOtp({required String identifier}) async {
    final response = await OTPWidget.sendOTP({'identifier': identifier});
    final map = _ensureSuccess(response);
    final reqId = (map['message'] ?? map['reqId'] ?? map['data']) as Object?;
    if (reqId == null || reqId.toString().isEmpty) {
      throw const ServerException('MSG91: missing reqId in send response');
    }
    return reqId.toString();
  }

  Future<void> verifyOtp({required String reqId, required String otp}) async {
    final response = await OTPWidget.verifyOTP({'reqId': reqId, 'otp': otp});
    _ensureSuccess(response);
  }

  /// Resends OTP via the given channel. SDK codes:
  ///   SMS = 11, VOICE = 4, EMAIL = 3, WHATSAPP = 12.
  Future<void> resendOtp({required String reqId, int channel = 11}) async {
    final response = await OTPWidget.retryOTP({
      'reqId': reqId,
      'retryChannel': channel,
    });
    _ensureSuccess(response);
  }

  Map<dynamic, dynamic> _ensureSuccess(dynamic response) {
    if (response is! Map) {
      throw const ServerException('MSG91: unexpected response shape');
    }
    final type = response['type']?.toString().toLowerCase();
    if (type == 'success') return response;
    final msg = response['message']?.toString() ?? 'MSG91 request failed';
    throw ServerException(msg, code: type);
  }
}
