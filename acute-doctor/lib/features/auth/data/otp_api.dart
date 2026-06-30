import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../onboarding/data/models/login_models.dart';
import 'models/otp_models.dart';

part 'otp_api.g.dart';

@RestApi()
abstract class OtpApi {
  factory OtpApi(Dio dio) = _OtpApi;

  @POST('/api/v1/otp/send')
  Future<void> sendOtp(@Body() OtpSendRequest body);

  @POST('/api/v1/otp/verify')
  Future<LoginResponse> verifyOtp(@Body() OtpVerifyRequest body);

  @POST('/api/v1/otp/resend')
  Future<void> resendOtp(@Body() OtpResendRequest body);
}
