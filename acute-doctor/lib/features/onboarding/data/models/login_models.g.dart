// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      accessToken: json['access_token'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
    };

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      token: json['token'] as String,
      isNew: json['is_new'] as bool,
      onboardingNeeded: json['onboarding_needed'] as bool,
      profileCompletion: (json['profile_completion'] as num).toInt(),
      tokenType: json['token_type'] as String? ?? 'bearer',
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'is_new': instance.isNew,
      'onboarding_needed': instance.onboardingNeeded,
      'profile_completion': instance.profileCompletion,
      'token_type': instance.tokenType,
    };
