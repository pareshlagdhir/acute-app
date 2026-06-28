// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Education _$EducationFromJson(Map<String, dynamic> json) => _Education(
      id: json['id'] as String,
      degree: json['degree'] as String,
      registrationNumber: json['registration_number'] as String,
      institution: json['institution'] as String?,
      yearOfCompletion: (json['year_of_completion'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EducationToJson(_Education instance) =>
    <String, dynamic>{
      'id': instance.id,
      'degree': instance.degree,
      'registration_number': instance.registrationNumber,
      'institution': instance.institution,
      'year_of_completion': instance.yearOfCompletion,
    };

_Speciality _$SpecialityFromJson(Map<String, dynamic> json) => _Speciality(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SpecialityToJson(_Speciality instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_Hospital _$HospitalFromJson(Map<String, dynamic> json) => _Hospital(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      city: json['city'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$HospitalToJson(_Hospital instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'city': instance.city,
      'address': instance.address,
    };

_WorkingHour _$WorkingHourFromJson(Map<String, dynamic> json) => _WorkingHour(
      id: json['id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );

Map<String, dynamic> _$WorkingHourToJson(_WorkingHour instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
    };

_Experience _$ExperienceFromJson(Map<String, dynamic> json) => _Experience(
      id: json['id'] as String,
      hospital: Hospital.fromJson(json['hospital'] as Map<String, dynamic>),
      designation: json['designation'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
      workingHours: (json['working_hours'] as List<dynamic>?)
              ?.map((e) => WorkingHour.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExperienceToJson(_Experience instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hospital': instance.hospital,
      'designation': instance.designation,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'is_current': instance.isCurrent,
      'working_hours': instance.workingHours,
    };

_DoctorProfile _$DoctorProfileFromJson(Map<String, dynamic> json) =>
    _DoctorProfile(
      id: json['id'] as String,
      mobile: json['mobile'] as String,
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      educations: (json['educations'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      specialities: (json['specialities'] as List<dynamic>?)
              ?.map((e) => Speciality.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      experiences: (json['experiences'] as List<dynamic>?)
              ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      profileCompletion: (json['profile_completion'] as num?)?.toInt() ?? 0,
      sections: (json['sections'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$DoctorProfileToJson(_DoctorProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile': instance.mobile,
      'first_name': instance.firstName,
      'middle_name': instance.middleName,
      'last_name': instance.lastName,
      'email': instance.email,
      'educations': instance.educations,
      'specialities': instance.specialities,
      'experiences': instance.experiences,
      'profile_completion': instance.profileCompletion,
      'sections': instance.sections,
    };

_CatalogItem _$CatalogItemFromJson(Map<String, dynamic> json) => _CatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$CatalogItemToJson(_CatalogItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
