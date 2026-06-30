import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_models.freezed.dart';
part 'otp_models.g.dart';

@freezed
abstract class OtpSendRequest with _$OtpSendRequest {
  const factory OtpSendRequest({required String mobile}) = _OtpSendRequest;
  factory OtpSendRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpSendRequestFromJson(json);
}

@freezed
abstract class OtpVerifyRequest with _$OtpVerifyRequest {
  const factory OtpVerifyRequest({
    required String mobile,
    required String otp,
  }) = _OtpVerifyRequest;
  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyRequestFromJson(json);
}

@freezed
abstract class OtpResendRequest with _$OtpResendRequest {
  const factory OtpResendRequest({
    required String mobile,
    @Default(false) bool voice,
  }) = _OtpResendRequest;
  factory OtpResendRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpResendRequestFromJson(json);
}
