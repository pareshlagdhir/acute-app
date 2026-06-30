import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'models/profile_models.dart';

part 'doctor_api.g.dart';

@RestApi()
abstract class DoctorApi {
  factory DoctorApi(Dio dio) = _DoctorApi;

  @GET('/api/v1/doctors/me')
  Future<DoctorProfile> getMe();

  @PATCH('/api/v1/doctors/me')
  Future<DoctorProfile> updatePersonal(@Body() Map<String, dynamic> body);

  @GET('/api/v1/catalog/degrees')
  Future<List<CatalogItem>> degrees(@Query('q') String? q);

  @GET('/api/v1/catalog/specialities')
  Future<List<CatalogItem>> specialities(@Query('q') String? q);

  @GET('/api/v1/hospitals')
  Future<List<Hospital>> searchHospitals(@Query('q') String? q);

  @POST('/api/v1/hospitals')
  Future<Hospital> createHospital(@Body() Map<String, dynamic> body);

  @POST('/api/v1/doctors/me/educations')
  Future<Education> addEducation(@Body() Map<String, dynamic> body);

  @PATCH('/api/v1/doctors/me/educations/{id}')
  Future<Education> updateEducation(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/api/v1/doctors/me/educations/{id}')
  Future<void> deleteEducation(@Path('id') String id);

  @POST('/api/v1/doctors/me/specialities')
  Future<Speciality> addSpeciality(@Body() Map<String, dynamic> body);

  @DELETE('/api/v1/doctors/me/specialities/{id}')
  Future<void> deleteSpeciality(@Path('id') String id);

  @POST('/api/v1/doctors/me/experiences')
  Future<Experience> addExperience(@Body() Map<String, dynamic> body);

  @PATCH('/api/v1/doctors/me/experiences/{id}')
  Future<Experience> updateExperience(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/api/v1/doctors/me/experiences/{id}')
  Future<void> deleteExperience(@Path('id') String id);

  @POST('/api/v1/doctors/me/experiences/{id}/working-hours')
  Future<WorkingHour> addWorkingHour(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/api/v1/doctors/me/experiences/{id}/working-hours/{wid}')
  Future<void> deleteWorkingHour(@Path('id') String id, @Path('wid') String wid);
}
