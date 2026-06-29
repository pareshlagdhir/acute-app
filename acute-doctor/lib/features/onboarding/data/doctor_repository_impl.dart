import 'package:dartz/dartz.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../domain/doctor_repository.dart';
import 'doctor_api.dart';
import 'models/login_models.dart';
import 'models/profile_models.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl(this._api);
  final DoctorApi _api;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on Object catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginResponse>> login(String accessToken) =>
      _guard(() => _api.login(LoginRequest(accessToken: accessToken)));

  @override
  Future<Either<Failure, DoctorProfile>> getMe() => _guard(_api.getMe);

  @override
  Future<Either<Failure, DoctorProfile>> updatePersonal({
    String? firstName, String? middleName, String? lastName, String? email,
  }) =>
      _guard(() => _api.updatePersonal({
            if (firstName != null) 'first_name': firstName,
            if (middleName != null) 'middle_name': middleName,
            if (lastName != null) 'last_name': lastName,
            if (email != null) 'email': email,
          }),);

  @override
  Future<Either<Failure, List<CatalogItem>>> searchDegrees(String? q) =>
      _guard(() => _api.degrees(q));

  @override
  Future<Either<Failure, List<CatalogItem>>> searchSpecialities(String? q) =>
      _guard(() => _api.specialities(q));

  @override
  Future<Either<Failure, List<Hospital>>> searchHospitals(String? q) =>
      _guard(() => _api.searchHospitals(q));

  @override
  Future<Either<Failure, Hospital>> createHospital({
    required String name, required String type, String? city, String? address,
  }) =>
      _guard(() => _api.createHospital({
            'name': name, 'type': type,
            if (city != null) 'city': city,
            if (address != null) 'address': address,
          }),);

  @override
  Future<Either<Failure, Education>> addEducation({
    required String degree, required String registrationNumber,
    String? institution, int? yearOfCompletion,
  }) =>
      _guard(() => _api.addEducation({
            'degree': degree, 'registration_number': registrationNumber,
            if (institution != null) 'institution': institution,
            if (yearOfCompletion != null) 'year_of_completion': yearOfCompletion,
          }),);

  @override
  Future<Either<Failure, Education>> updateEducation(String id, Map<String, dynamic> changes) =>
      _guard(() => _api.updateEducation(id, changes));

  @override
  Future<Either<Failure, Unit>> deleteEducation(String id) =>
      _guard(() async { await _api.deleteEducation(id); return unit; });

  @override
  Future<Either<Failure, Speciality>> addSpeciality(String name) =>
      _guard(() => _api.addSpeciality({'name': name}));

  @override
  Future<Either<Failure, Unit>> deleteSpeciality(String id) =>
      _guard(() async { await _api.deleteSpeciality(id); return unit; });

  @override
  Future<Either<Failure, Experience>> addExperience({
    required String hospitalId, String? designation,
    String? startDate, String? endDate, bool? isCurrent,
  }) =>
      _guard(() => _api.addExperience({
            'hospital_id': hospitalId, 'is_current': isCurrent ?? false,
            if (designation != null) 'designation': designation,
            if (startDate != null) 'start_date': startDate,
            if (endDate != null) 'end_date': endDate,
          }),);

  @override
  Future<Either<Failure, Experience>> updateExperience(String id, Map<String, dynamic> changes) =>
      _guard(() => _api.updateExperience(id, changes));

  @override
  Future<Either<Failure, Unit>> deleteExperience(String id) =>
      _guard(() async { await _api.deleteExperience(id); return unit; });

  @override
  Future<Either<Failure, WorkingHour>> addWorkingHour({
    required String experienceId, required int dayOfWeek,
    required String startTime, required String endTime,
  }) =>
      _guard(() => _api.addWorkingHour(experienceId, {
            'day_of_week': dayOfWeek, 'start_time': startTime, 'end_time': endTime,
          }),);

  @override
  Future<Either<Failure, Unit>> deleteWorkingHour(String experienceId, String wid) =>
      _guard(() async { await _api.deleteWorkingHour(experienceId, wid); return unit; });
}
