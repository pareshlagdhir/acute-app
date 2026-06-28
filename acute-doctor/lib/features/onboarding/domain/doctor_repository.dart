import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../data/models/login_models.dart';
import '../data/models/profile_models.dart';

abstract interface class DoctorRepository {
  Future<Either<Failure, LoginResponse>> login(String accessToken);
  Future<Either<Failure, DoctorProfile>> getMe();
  Future<Either<Failure, DoctorProfile>> updatePersonal({
    String? firstName, String? middleName, String? lastName, String? email,
  });
  Future<Either<Failure, List<CatalogItem>>> searchDegrees(String? q);
  Future<Either<Failure, List<CatalogItem>>> searchSpecialities(String? q);
  Future<Either<Failure, List<Hospital>>> searchHospitals(String? q);
  Future<Either<Failure, Hospital>> createHospital({
    required String name, required String type, String? city, String? address,
  });
  Future<Either<Failure, Education>> addEducation({
    required String degree, required String registrationNumber,
    String? institution, int? yearOfCompletion,
  });
  Future<Either<Failure, Education>> updateEducation(String id, Map<String, dynamic> changes);
  Future<Either<Failure, Unit>> deleteEducation(String id);
  Future<Either<Failure, Speciality>> addSpeciality(String name);
  Future<Either<Failure, Unit>> deleteSpeciality(String id);
  Future<Either<Failure, Experience>> addExperience({
    required String hospitalId, String? designation,
    String? startDate, String? endDate, bool isCurrent,
  });
  Future<Either<Failure, Experience>> updateExperience(String id, Map<String, dynamic> changes);
  Future<Either<Failure, Unit>> deleteExperience(String id);
  Future<Either<Failure, WorkingHour>> addWorkingHour({
    required String experienceId, required int dayOfWeek,
    required String startTime, required String endTime,
  });
  Future<Either<Failure, Unit>> deleteWorkingHour(String experienceId, String wid);
}
