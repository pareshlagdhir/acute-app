import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_models.freezed.dart';
part 'login_models.g.dart';

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String token,
    @JsonKey(name: 'is_new') required bool isNew,
    @JsonKey(name: 'onboarding_needed') required bool onboardingNeeded,
    @JsonKey(name: 'profile_completion') required int profileCompletion,
    @JsonKey(name: 'token_type') @Default('bearer') String tokenType,
  }) = _LoginResponse;
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
