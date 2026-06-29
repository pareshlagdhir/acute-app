import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

@freezed
abstract class Education with _$Education {
  const factory Education({
    required String id,
    required String degree,
    @JsonKey(name: 'registration_number') required String registrationNumber,
    String? institution,
    @JsonKey(name: 'year_of_completion') int? yearOfCompletion,
  }) = _Education;
  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);
}

@freezed
abstract class Speciality with _$Speciality {
  const factory Speciality({required String id, required String name}) =
      _Speciality;
  factory Speciality.fromJson(Map<String, dynamic> json) =>
      _$SpecialityFromJson(json);
}

@freezed
abstract class Hospital with _$Hospital {
  const factory Hospital({
    required String id,
    required String name,
    required String type,
    String? city,
    String? address,
  }) = _Hospital;
  factory Hospital.fromJson(Map<String, dynamic> json) =>
      _$HospitalFromJson(json);
}

@freezed
abstract class WorkingHour with _$WorkingHour {
  const factory WorkingHour({
    required String id,
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
  }) = _WorkingHour;
  factory WorkingHour.fromJson(Map<String, dynamic> json) =>
      _$WorkingHourFromJson(json);
}

@freezed
abstract class Experience with _$Experience {
  const factory Experience({
    required String id,
    required Hospital hospital,
    String? designation,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'is_current') @Default(false) bool isCurrent,
    @JsonKey(name: 'working_hours') @Default([]) List<WorkingHour> workingHours,
  }) = _Experience;
  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);
}

@freezed
abstract class DoctorProfile with _$DoctorProfile {
  const factory DoctorProfile({
    required String id,
    required String mobile,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'middle_name') String? middleName,
    @JsonKey(name: 'last_name') String? lastName,
    String? email,
    @Default([]) List<Education> educations,
    @Default([]) List<Speciality> specialities,
    @Default([]) List<Experience> experiences,
    @JsonKey(name: 'profile_completion') @Default(0) int profileCompletion,
    @Default({}) Map<String, bool> sections,
  }) = _DoctorProfile;
  factory DoctorProfile.fromJson(Map<String, dynamic> json) =>
      _$DoctorProfileFromJson(json);
}

@freezed
abstract class CatalogItem with _$CatalogItem {
  const factory CatalogItem({required String id, required String name}) =
      _CatalogItem;
  factory CatalogItem.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemFromJson(json);
}
