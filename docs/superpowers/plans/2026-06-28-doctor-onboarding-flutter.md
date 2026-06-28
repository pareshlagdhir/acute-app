# Doctor Onboarding — Flutter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the Flutter app to the onboarding backend: exchange the MSG91 widget access token for a JWT session, route registered vs. new doctors, and build a skippable onboarding hub (with a completion bar) plus per-section forms backed by the `/doctors/me/*` API.

**Architecture:** Clean Architecture per feature (`data` / `domain` / `presentation`), Riverpod state, Retrofit + Dio data sources, Freezed models. The existing `auth` feature gains a backend session exchange; `profile_setup` becomes the onboarding hub; a new `onboarding` data/domain layer holds the doctor profile repository shared with the `profile` feature for later edits.

**Tech Stack:** Flutter, Riverpod 2 + riverpod_generator, go_router, Dio + Retrofit (retrofit_generator), Freezed + json_serializable, flutter_secure_storage, sendotp_flutter_sdk, mocktail (tests).

## Global Constraints

- Clean Architecture layering per feature: `data/` (datasources, models, repo impl), `domain/` (entities, repo abstraction), `presentation/` (riverpod controllers, pages, widgets).
- Riverpod with `riverpod_generator`; run `dart run build_runner build --delete-conflicting-outputs` after editing annotated classes.
- Networking via the existing `DioClient.create` + `AuthInterceptor` (reads token from secure storage). API base URL from `AppConfig.I.apiBaseUrl`; all paths are relative to it and prefixed `/api/v1`.
- Repositories return `Either<Failure, T>` (dartz) and map `AppException`s exactly as `OtpRepositoryImpl._guard` does.
- Use `AcuteTheme` design tokens (`AppColors`, `AppSpacing`, `AppTypography`, `AppRadii`) and shared widgets (`AcuteButton`, etc.) — never hard-code colors/sizes.
- Run `flutter analyze` clean and `flutter test` green before each commit.
- The completion percentage is read from the backend (`profile_completion`), never recomputed on-device.

## API Contract (from the backend plan)

```
POST /api/v1/auth/login        {access_token} -> {token, token_type, is_new, onboarding_needed, profile_completion}
GET  /api/v1/doctors/me        -> {id, mobile, first_name, middle_name, last_name, email,
                                    educations[], specialities[], experiences[], profile_completion, sections{}}
PATCH/api/v1/doctors/me        {first_name?, middle_name?, last_name?, email?}
GET  /api/v1/catalog/degrees?q=        -> [{id, name}]
GET  /api/v1/catalog/specialities?q=   -> [{id, name}]
GET  /api/v1/hospitals?q=              -> [{id, name, type, city, address}]
POST /api/v1/hospitals                 {name, type, city?, address?} -> hospital
POST   /api/v1/doctors/me/educations          {degree, registration_number, institution?, year_of_completion?}
PATCH  /api/v1/doctors/me/educations/{id}
DELETE /api/v1/doctors/me/educations/{id}
POST   /api/v1/doctors/me/specialities        {name}
DELETE /api/v1/doctors/me/specialities/{id}
POST   /api/v1/doctors/me/experiences         {hospital_id, designation?, start_date?, end_date?, is_current}
PATCH  /api/v1/doctors/me/experiences/{id}
DELETE /api/v1/doctors/me/experiences/{id}
GET    /api/v1/doctors/me/experiences/{id}/working-hours
POST   /api/v1/doctors/me/experiences/{id}/working-hours   {day_of_week, start_time, end_time}
DELETE /api/v1/doctors/me/experiences/{id}/working-hours/{wid}
```

---

## File Structure

- `lib/core/network/dio_provider.dart` (create) — Riverpod-provided `Dio` wired to secure storage token.
- `lib/features/onboarding/data/models/*.dart` (create) — Freezed DTOs for login + profile + sub-resources.
- `lib/features/onboarding/data/doctor_api.dart` (create) — Retrofit client.
- `lib/features/onboarding/data/doctor_repository_impl.dart` (create).
- `lib/features/onboarding/domain/doctor_repository.dart` (create) — abstraction + entities (reuse Freezed models as entities).
- `lib/features/onboarding/presentation/providers/onboarding_providers.dart` (create) — repo provider + `profileControllerProvider`.
- `lib/features/profile_setup/presentation/pages/onboarding_hub_page.dart` (create) — replaces role-picker stub.
- `lib/features/profile_setup/presentation/pages/sections/*.dart` (create) — personal, education, speciality, experience, working-hours forms.
- `lib/features/auth/data/otp_repository_impl.dart` (modify) — capture access token; add `loginWithToken`.
- `lib/features/auth/presentation/providers/auth_providers.dart` (modify) — store login result, expose `onboardingNeeded`.
- `lib/features/auth/presentation/pages/otp_page.dart` (modify) — route by `onboarding_needed`.
- `lib/core/routing/app_routes.dart` + `app_router.dart` (modify) — section routes + auth redirect guard.

---

### Task F1: Dio provider wired to secure storage

**Files:**
- Create: `acute-doctor/lib/core/network/dio_provider.dart`
- Test: `acute-doctor/test/core/network/dio_provider_test.dart`

**Interfaces:**
- Consumes: `DioClient.create({tokenProvider})`, `SecureStorage`.
- Produces: `secureStorageProvider` (Provider<SecureStorage>), `authTokenProvider` (StateProvider<String?> holding the cached JWT), `dioProvider` (Provider<Dio>) whose `tokenProvider` returns the cached token.

- [ ] **Step 1: Write the failing test**

Create `test/core/network/dio_provider_test.dart`:

```dart
import 'package:acute_doctor/core/network/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dioProvider builds a Dio with base options', () {
    // AppConfig must be initialized for DioClient.create; init a dev config.
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final dio = container.read(dioProvider);
    expect(dio, isA<Dio>());
  });
}
```

Note: the test requires `AppConfig.init(...)` first. Add a `setUpAll` that calls `AppConfig.init(flavor: Flavor.dev, appName: 'test', apiBaseUrl: 'http://localhost:8000')` importing `package:acute_doctor/core/config/app_config.dart`.

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/core/network/dio_provider_test.dart`
Expected: FAIL — `dio_provider.dart` does not exist.

- [ ] **Step 3: Implement the providers**

Create `lib/core/network/dio_provider.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/secure_storage.dart';
import 'dio_client.dart';

final secureStorageProvider = Provider<SecureStorage>(
  (ref) => SecureStorage(const FlutterSecureStorage()),
);

/// In-memory cache of the JWT so the Dio interceptor reads it synchronously.
/// Seeded from secure storage at app start (see router bootstrap).
final authTokenProvider = StateProvider<String?>((ref) => null);

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(tokenProvider: () => ref.read(authTokenProvider));
});
```

- [ ] **Step 4: Run to verify it passes**

Run: `flutter test test/core/network/dio_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/network/dio_provider.dart test/core/network/dio_provider_test.dart
git commit -m "feat(app): add Riverpod Dio provider wired to JWT token"
```

---

### Task F2: Freezed DTOs and Retrofit `DoctorApi`

**Files:**
- Create: `acute-doctor/lib/features/onboarding/data/models/login_models.dart`
- Create: `acute-doctor/lib/features/onboarding/data/models/profile_models.dart`
- Create: `acute-doctor/lib/features/onboarding/data/doctor_api.dart`
- Test: `acute-doctor/test/features/onboarding/profile_models_test.dart`

**Interfaces:**
- Produces Freezed/json classes: `LoginRequest{accessToken}`, `LoginResponse{token, tokenType, isNew, onboardingNeeded, profileCompletion}`, `DoctorProfile{..., educations, specialities, experiences, profileCompletion, sections}`, `Education`, `Speciality`, `Experience{..., hospital, workingHours}`, `Hospital`, `WorkingHour`, `CatalogItem`, and create/update request bodies.
- Produces `DoctorApi` (Retrofit) with one method per contract route.

- [ ] **Step 1: Write the failing model test**

Create `test/features/onboarding/profile_models_test.dart`:

```dart
import 'package:acute_doctor/features/onboarding/data/models/profile_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DoctorProfile parses backend JSON', () {
    final json = {
      'id': 'd1', 'mobile': '919876543210',
      'first_name': 'Asha', 'middle_name': null, 'last_name': 'Rao', 'email': null,
      'educations': [
        {'id': 'e1', 'degree': 'MBBS', 'registration_number': 'R1',
         'institution': null, 'year_of_completion': null}
      ],
      'specialities': [{'id': 's1', 'name': 'Cardiology'}],
      'experiences': [],
      'profile_completion': 40,
      'sections': {'personal': true, 'education': true, 'speciality': true,
                   'experience': false, 'working_hours': false},
    };
    final p = DoctorProfile.fromJson(json);
    expect(p.profileCompletion, 40);
    expect(p.educations.single.degree, 'MBBS');
    expect(p.sections['experience'], false);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/onboarding/profile_models_test.dart`
Expected: FAIL — `profile_models.dart` missing.

- [ ] **Step 3: Implement the models**

Create `lib/features/onboarding/data/models/login_models.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_models.freezed.dart';
part 'login_models.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    @JsonKey(name: 'access_token') required String accessToken,
  }) = _LoginRequest;
  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String token,
    @JsonKey(name: 'token_type') @Default('bearer') String tokenType,
    @JsonKey(name: 'is_new') required bool isNew,
    @JsonKey(name: 'onboarding_needed') required bool onboardingNeeded,
    @JsonKey(name: 'profile_completion') required int profileCompletion,
  }) = _LoginResponse;
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
```

Create `lib/features/onboarding/data/models/profile_models.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

@freezed
class Education with _$Education {
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
class Speciality with _$Speciality {
  const factory Speciality({required String id, required String name}) =
      _Speciality;
  factory Speciality.fromJson(Map<String, dynamic> json) =>
      _$SpecialityFromJson(json);
}

@freezed
class Hospital with _$Hospital {
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
class WorkingHour with _$WorkingHour {
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
class Experience with _$Experience {
  const factory Experience({
    required String id,
    String? designation,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'is_current') @Default(false) bool isCurrent,
    required Hospital hospital,
    @JsonKey(name: 'working_hours') @Default([]) List<WorkingHour> workingHours,
  }) = _Experience;
  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);
}

@freezed
class DoctorProfile with _$DoctorProfile {
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
class CatalogItem with _$CatalogItem {
  const factory CatalogItem({required String id, required String name}) =
      _CatalogItem;
  factory CatalogItem.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemFromJson(json);
}
```

- [ ] **Step 4: Implement the Retrofit client**

Create `lib/features/onboarding/data/doctor_api.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'models/login_models.dart';
import 'models/profile_models.dart';

part 'doctor_api.g.dart';

@RestApi()
abstract class DoctorApi {
  factory DoctorApi(Dio dio) = _DoctorApi;

  @POST('/api/v1/auth/login')
  Future<LoginResponse> login(@Body() LoginRequest body);

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
```

- [ ] **Step 5: Generate code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: generates `*.freezed.dart`, `*.g.dart`, `doctor_api.g.dart` with no errors.

- [ ] **Step 6: Run the model test**

Run: `flutter test test/features/onboarding/profile_models_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/onboarding/data test/features/onboarding/profile_models_test.dart
git commit -m "feat(app): add onboarding DTOs and Retrofit DoctorApi"
```

---

### Task F3: Doctor repository (domain + impl)

**Files:**
- Create: `acute-doctor/lib/features/onboarding/domain/doctor_repository.dart`
- Create: `acute-doctor/lib/features/onboarding/data/doctor_repository_impl.dart`
- Test: `acute-doctor/test/features/onboarding/doctor_repository_test.dart`

**Interfaces:**
- Consumes: `DoctorApi` (F2), `Failure`/`AppException` (core).
- Produces `DoctorRepository` abstraction with methods returning `Either<Failure, T>`: `login(String accessToken)`, `getMe()`, `updatePersonal({firstName,middleName,lastName,email})`, `searchDegrees(q)`, `searchSpecialities(q)`, `searchHospitals(q)`, `createHospital({name,type,city,address})`, `addEducation(...)`, `updateEducation(...)`, `deleteEducation(id)`, `addSpeciality(name)`, `deleteSpeciality(id)`, `addExperience(...)`, `updateExperience(...)`, `deleteExperience(id)`, `addWorkingHour(...)`, `deleteWorkingHour(expId, wid)`.

- [ ] **Step 1: Write the failing test (with a mocked api)**

Create `test/features/onboarding/doctor_repository_test.dart`:

```dart
import 'package:acute_doctor/core/errors/exceptions.dart';
import 'package:acute_doctor/core/errors/failures.dart';
import 'package:acute_doctor/features/onboarding/data/doctor_api.dart';
import 'package:acute_doctor/features/onboarding/data/doctor_repository_impl.dart';
import 'package:acute_doctor/features/onboarding/data/models/login_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements DoctorApi {}

void main() {
  setUpAll(() => registerFallbackValue(const LoginRequest(accessToken: 'x')));

  test('login success returns Right(LoginResponse)', () async {
    final api = _MockApi();
    when(() => api.login(any())).thenAnswer((_) async => const LoginResponse(
          token: 'jwt', isNew: true, onboardingNeeded: true, profileCompletion: 0,
        ));
    final repo = DoctorRepositoryImpl(api);
    final res = await repo.login('tok');
    expect(res.isRight(), true);
  });

  test('server exception maps to ServerFailure', () async {
    final api = _MockApi();
    when(() => api.login(any())).thenThrow(const ServerException('boom', code: '401'));
    final repo = DoctorRepositoryImpl(api);
    final res = await repo.login('tok');
    res.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected Left'));
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/onboarding/doctor_repository_test.dart`
Expected: FAIL — repo files missing.

- [ ] **Step 3: Define the abstraction**

Create `lib/features/onboarding/domain/doctor_repository.dart`:

```dart
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
```

- [ ] **Step 4: Implement**

Create `lib/features/onboarding/data/doctor_repository_impl.dart`:

```dart
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
          }));

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
          }));

  @override
  Future<Either<Failure, Education>> addEducation({
    required String degree, required String registrationNumber,
    String? institution, int? yearOfCompletion,
  }) =>
      _guard(() => _api.addEducation({
            'degree': degree, 'registration_number': registrationNumber,
            if (institution != null) 'institution': institution,
            if (yearOfCompletion != null) 'year_of_completion': yearOfCompletion,
          }));

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
    String? startDate, String? endDate, bool isCurrent = false,
  }) =>
      _guard(() => _api.addExperience({
            'hospital_id': hospitalId, 'is_current': isCurrent,
            if (designation != null) 'designation': designation,
            if (startDate != null) 'start_date': startDate,
            if (endDate != null) 'end_date': endDate,
          }));

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
          }));

  @override
  Future<Either<Failure, Unit>> deleteWorkingHour(String experienceId, String wid) =>
      _guard(() async { await _api.deleteWorkingHour(experienceId, wid); return unit; });
}
```

- [ ] **Step 5: Run, then commit**

Run: `flutter test test/features/onboarding/doctor_repository_test.dart` → PASS.

```bash
git add lib/features/onboarding/domain lib/features/onboarding/data/doctor_repository_impl.dart test/features/onboarding/doctor_repository_test.dart
git commit -m "feat(app): add doctor repository (domain + impl)"
```

---

### Task F4: Login session exchange + auth state

**Files:**
- Create: `acute-doctor/lib/features/onboarding/presentation/providers/onboarding_providers.dart`
- Modify: `acute-doctor/lib/features/auth/data/msg91_otp_service.dart`
- Modify: `acute-doctor/lib/features/auth/data/otp_repository_impl.dart`
- Modify: `acute-doctor/lib/features/auth/domain/otp_repository.dart`
- Modify: `acute-doctor/lib/features/auth/presentation/providers/auth_providers.dart`
- Test: `acute-doctor/test/features/auth/login_exchange_test.dart`

**Interfaces:**
- `Msg91OtpService.verifyOtp` returns the access token `String` (the widget success `message`) instead of `void`.
- `OtpRepository.verifyOtp(...)` returns `Either<Failure, String>` (the access token).
- Produces: `doctorRepositoryProvider` (Provider<DoctorRepository>), and an `AuthController.verifyOtp` that on success calls `doctorRepository.login(accessToken)`, stores `token` via `SecureStorage.writeAuthToken` and sets `authTokenProvider`, and records `onboardingNeeded` in `AuthState`.

- [ ] **Step 1: Write the failing test**

Create `test/features/auth/login_exchange_test.dart`:

```dart
import 'package:acute_doctor/core/errors/failures.dart';
import 'package:acute_doctor/features/onboarding/data/models/login_models.dart';
import 'package:acute_doctor/features/onboarding/domain/doctor_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  test('login exchange returns onboardingNeeded flag', () async {
    final repo = _MockRepo();
    when(() => repo.login('tok')).thenAnswer((_) async => const Right(
          LoginResponse(token: 'jwt', isNew: true, onboardingNeeded: true, profileCompletion: 0),
        ));
    final res = await repo.login('tok');
    res.fold((_) => fail('expected Right'), (r) {
      expect(r.token, 'jwt');
      expect(r.onboardingNeeded, true);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/auth/login_exchange_test.dart`
Expected: FAIL until the imports resolve (they exist after F2/F3); this guards the contract.

- [ ] **Step 3: Make the widget verify return the access token**

In `lib/features/auth/data/msg91_otp_service.dart`, change `verifyOtp` to return the token:

```dart
  /// Verifies the OTP and returns the MSG91 access token (the success
  /// `message`) that the backend exchanges for a session.
  Future<String> verifyOtp({required String reqId, required String otp}) async {
    final response = await OTPWidget.verifyOTP({'reqId': reqId, 'otp': otp});
    final map = _ensureSuccess(response);
    final token = (map['message'] ?? map['accessToken']) as Object?;
    if (token == null || token.toString().isEmpty) {
      throw const ServerException('MSG91: missing access token after verify');
    }
    return token.toString();
  }
```

- [ ] **Step 4: Thread the token through the OTP repository**

In `lib/features/auth/domain/otp_repository.dart`, change the `verifyOtp` signature return type to `Future<Either<Failure, String>>`.

In `lib/features/auth/data/otp_repository_impl.dart`, replace the `verifyOtp` body:

```dart
  @override
  Future<Either<Failure, String>> verifyOtp({
    required String reqId,
    required String mobile,
    required String otp,
  }) async {
    return _guard(() async {
      final accessToken = await _service.verifyOtp(reqId: reqId, otp: otp);
      return accessToken;
    });
  }
```

(The `_secureStorage` write of the `otp-verified:` marker is removed; the JWT is stored by the controller after the backend exchange.)

- [ ] **Step 5: Add the onboarding providers**

Create `lib/features/onboarding/presentation/providers/onboarding_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/doctor_api.dart';
import '../../data/doctor_repository_impl.dart';
import '../../domain/doctor_repository.dart';

final doctorApiProvider = Provider<DoctorApi>(
  (ref) => DoctorApi(ref.watch(dioProvider)),
);

final doctorRepositoryProvider = Provider<DoctorRepository>(
  (ref) => DoctorRepositoryImpl(ref.watch(doctorApiProvider)),
);
```

- [ ] **Step 6: Update `AuthController.verifyOtp` to exchange the token**

In `lib/features/auth/presentation/providers/auth_providers.dart`:
1. Add fields to `AuthState`: `final bool onboardingNeeded;` (default `false`) plus copyWith handling mirroring the existing sentinel pattern.
2. Inject the new providers in `build()`:

```dart
  late final DoctorRepository _doctorRepo;
  late final SecureStorage _storage;

  @override
  AuthState build() {
    _repo = ref.watch(otpRepositoryProvider);
    _doctorRepo = ref.watch(doctorRepositoryProvider);
    _storage = ref.watch(secureStorageProvider);
    return const AuthState();
  }
```

3. Replace the `verifyOtp` success branch to exchange and store the token:

```dart
  Future<bool> verifyOtp(String otp) async {
    final reqId = state.reqId;
    final mobile = state.mobile;
    if (reqId == null || mobile == null) {
      state = state.copyWith(error: 'Please request a new code');
      return false;
    }
    state = state.copyWith(isVerifying: true, error: null);
    final res = await _repo.verifyOtp(reqId: reqId, mobile: mobile, otp: otp);
    return res.fold(
      (f) {
        state = state.copyWith(isVerifying: false, error: _message(f));
        return false;
      },
      (accessToken) async => _exchange(accessToken, mobile),
    ).then((v) => v is Future<bool> ? v : Future.value(v));
  }

  Future<bool> _exchange(String accessToken, String mobile) async {
    final login = await _doctorRepo.login(accessToken);
    return login.fold(
      (f) {
        state = state.copyWith(isVerifying: false, error: _message(f));
        return false;
      },
      (resp) async {
        await _storage.writeAuthToken(resp.token);
        ref.read(authTokenProvider.notifier).state = resp.token;
        state = state.copyWith(
          isVerifying: false,
          verifiedMobile: mobile,
          onboardingNeeded: resp.onboardingNeeded,
        );
        return true;
      },
    );
  }
```

Import `secureStorageProvider` and `authTokenProvider` from `core/network/dio_provider.dart` and `doctorRepositoryProvider` from the onboarding providers.

- [ ] **Step 7: Generate, analyze, test, commit**

Run:
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test test/features/auth/login_exchange_test.dart test/features/onboarding/
```
Expected: analyze clean, tests PASS.

```bash
git add lib/features/auth lib/features/onboarding/presentation/providers/onboarding_providers.dart test/features/auth/login_exchange_test.dart
git commit -m "feat(app): exchange MSG91 token for backend session on verify"
```

---

### Task F5: Routing — section routes + auth redirect + bootstrap token

**Files:**
- Modify: `acute-doctor/lib/core/routing/app_routes.dart`
- Modify: `acute-doctor/lib/core/routing/app_router.dart`
- Modify: `acute-doctor/lib/features/auth/presentation/pages/otp_page.dart`
- Test: `acute-doctor/test/core/routing/app_routes_test.dart`

**Interfaces:**
- Adds routes: `onboardingPersonal`, `onboardingEducation`, `onboardingSpeciality`, `onboardingExperience`, `onboardingWorkingHours` (under `/onboarding/...`).
- OTP page routes to `AppRoutes.profileSetup` when `onboardingNeeded`, else `AppRoutes.home`.
- Router seeds `authTokenProvider` from secure storage at construction and redirects unauthenticated users to `login` for guarded routes.

- [ ] **Step 1: Add route constants + failing test**

In `lib/core/routing/app_routes.dart`, add:

```dart
  static const String onboardingPersonal = '/onboarding/personal';
  static const String onboardingEducation = '/onboarding/education';
  static const String onboardingSpeciality = '/onboarding/speciality';
  static const String onboardingExperience = '/onboarding/experience';
  static const String onboardingWorkingHours = '/onboarding/working-hours';
```

Create `test/core/routing/app_routes_test.dart`:

```dart
import 'package:acute_doctor/core/routing/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding section routes are under /onboarding', () {
    expect(AppRoutes.onboardingPersonal, '/onboarding/personal');
    expect(AppRoutes.onboardingWorkingHours, '/onboarding/working-hours');
  });
}
```

Run: `flutter test test/core/routing/app_routes_test.dart` → PASS (constants exist).

- [ ] **Step 2: Register routes + redirect in `app_router.dart`**

Add `GoRoute`s for the five section pages (pages built in F7–F11; for now point them at placeholders that are replaced as those tasks land) and replace `profileSetup`'s builder with `OnboardingHubPage` (F6). Add a `redirect` that sends users without a token to `login` for guarded paths (`home`, `alerts`, `profile`, `/onboarding/...`). Seed the token synchronously before building the router. Example wiring:

```dart
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final token = ref.read(authTokenProvider);
      final loc = state.matchedLocation;
      final guarded = loc == AppRoutes.home ||
          loc == AppRoutes.alerts ||
          loc == AppRoutes.profile ||
          loc.startsWith('/onboarding');
      if (guarded && (token == null || token.isEmpty)) return AppRoutes.login;
      return null;
    },
    routes: [ /* existing + section routes */ ],
  );
});
```

The splash page (existing) is responsible for reading the stored token into `authTokenProvider` at startup; add in its init: `ref.read(authTokenProvider.notifier).state = await ref.read(secureStorageProvider).readAuthToken();` then navigate to `home` if a token exists, else `login`.

- [ ] **Step 3: Route OTP completion by onboardingNeeded**

In `otp_page.dart`, replace the success branch of `_onCompleted`:

```dart
    if (ok) {
      final needsOnboarding = ref.read(authControllerProvider).onboardingNeeded;
      context.go(needsOnboarding ? AppRoutes.profileSetup : AppRoutes.home);
    } else {
      _controller.clear();
    }
```

- [ ] **Step 4: Generate, analyze, test, commit**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test test/core/routing/`
Expected: clean + PASS.

```bash
git add lib/core/routing lib/features/auth/presentation/pages/otp_page.dart lib/features/splash test/core/routing/app_routes_test.dart
git commit -m "feat(app): onboarding routes, auth redirect, token bootstrap"
```

---

### Task F6: Profile controller + onboarding hub page

**Files:**
- Modify: `acute-doctor/lib/features/onboarding/presentation/providers/onboarding_providers.dart`
- Create: `acute-doctor/lib/features/profile_setup/presentation/pages/onboarding_hub_page.dart`
- Replace: route builder for `profileSetup` (done in F5) now points here.
- Test: `acute-doctor/test/features/onboarding/profile_controller_test.dart`

**Interfaces:**
- Produces `profileControllerProvider` — an `AsyncNotifierProvider<ProfileController, DoctorProfile>` exposing `Future<void> refresh()` and convenience getters; it calls `doctorRepository.getMe()`.
- `OnboardingHubPage` reads it, renders a completion bar (`profileCompletion`) and five tiles whose done-state comes from `sections`, each navigating to its section route; plus a persistent "Continue to dashboard" action → `AppRoutes.home`.

- [ ] **Step 1: Write the failing controller test**

Create `test/features/onboarding/profile_controller_test.dart`:

```dart
import 'package:acute_doctor/core/errors/failures.dart';
import 'package:acute_doctor/features/onboarding/data/models/profile_models.dart';
import 'package:acute_doctor/features/onboarding/domain/doctor_repository.dart';
import 'package:acute_doctor/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  test('profileController loads profile from repository', () async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer((_) async => const Right(
          DoctorProfile(id: 'd1', mobile: '91', profileCompletion: 20,
              sections: {'personal': true}),
        ));
    final container = ProviderContainer(overrides: [
      doctorRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
    final profile = await container.read(profileControllerProvider.future);
    expect(profile.profileCompletion, 20);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/onboarding/profile_controller_test.dart`
Expected: FAIL — `profileControllerProvider` undefined.

- [ ] **Step 3: Implement the controller**

Append to `lib/features/onboarding/presentation/providers/onboarding_providers.dart`:

```dart
import '../../data/models/profile_models.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, DoctorProfile>(ProfileController.new);

class ProfileController extends AsyncNotifier<DoctorProfile> {
  @override
  Future<DoctorProfile> build() => _load();

  Future<DoctorProfile> _load() async {
    final res = await ref.read(doctorRepositoryProvider).getMe();
    return res.fold((f) => throw Exception(f.message), (p) => p);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `flutter test test/features/onboarding/profile_controller_test.dart`
Expected: PASS.

- [ ] **Step 5: Build the hub page**

Create `lib/features/profile_setup/presentation/pages/onboarding_hub_page.dart`. Use `AppColors/AppSpacing/AppTypography`, a `LinearProgressIndicator` bound to `profileCompletion / 100`, and five tiles from a static list mapping section key → label/icon/route. Each tile shows a check when `profile.sections[key] == true`. Bottom `AcuteButton(label: 'Continue to dashboard')` → `context.go(AppRoutes.home)`. Watch `profileControllerProvider`; on `loading`/`error` show a spinner / retry. Skeleton:

```dart
class OnboardingHubPage extends ConsumerWidget {
  const OnboardingHubPage({super.key});

  static const _sections = <(_SectionKey, String, IconData, String)>[
    (_SectionKey.personal, 'Personal information', Icons.person_outline, AppRoutes.onboardingPersonal),
    (_SectionKey.education, 'Education & registration', Icons.school_outlined, AppRoutes.onboardingEducation),
    (_SectionKey.speciality, 'Specialities', Icons.stethoscope, AppRoutes.onboardingSpeciality),
    (_SectionKey.experience, 'Experience', Icons.work_outline, AppRoutes.onboardingExperience),
    (_SectionKey.workingHours, 'Working hours', Icons.schedule_outlined, AppRoutes.onboardingWorkingHours),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load profile: $e')),
        data: (profile) => _HubBody(profile: profile),
      ),
    );
  }
}
```

`_HubBody` renders the progress bar (`'${profile.profileCompletion}% complete'`), the tiles (tap → `context.push(route)` then `ref.read(profileControllerProvider.notifier).refresh()` on return), and the continue button. Map `_SectionKey` to the backend `sections` keys (`personal`, `education`, `speciality`, `experience`, `working_hours`).

- [ ] **Step 6: Analyze, test, commit**

Run: `flutter analyze && flutter test test/features/onboarding/`
Expected: clean + PASS.

```bash
git add lib/features/onboarding/presentation/providers/onboarding_providers.dart lib/features/profile_setup/presentation/pages/onboarding_hub_page.dart test/features/onboarding/profile_controller_test.dart
git commit -m "feat(app): add profile controller and onboarding hub"
```

---

### Task F7: Personal information form

**Files:**
- Create: `acute-doctor/lib/features/profile_setup/presentation/pages/sections/personal_info_page.dart`
- Test: `acute-doctor/test/features/onboarding/personal_info_page_test.dart`

**Interfaces:**
- Consumes: `profileControllerProvider`, `doctorRepositoryProvider.updatePersonal`.
- A form with first/middle/last name + email fields, prefilled from the current `DoctorProfile`; Save calls `updatePersonal`, then `profileController.refresh()`, then pops.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/onboarding/personal_info_page_test.dart`:

```dart
import 'package:acute_doctor/core/errors/failures.dart';
import 'package:acute_doctor/features/onboarding/data/models/profile_models.dart';
import 'package:acute_doctor/features/onboarding/domain/doctor_repository.dart';
import 'package:acute_doctor/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:acute_doctor/features/profile_setup/presentation/pages/sections/personal_info_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  testWidgets('renders name fields prefilled', (tester) async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer((_) async => const Right(
          DoctorProfile(id: 'd', mobile: '91', firstName: 'Asha', lastName: 'Rao'),
        ));
    await tester.pumpWidget(ProviderScope(
      overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: PersonalInfoPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('Rao'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/onboarding/personal_info_page_test.dart` → FAIL (page missing).

- [ ] **Step 3: Implement the page**

Create `personal_info_page.dart`: a `ConsumerStatefulWidget` that watches `profileControllerProvider`, seeds `TextEditingController`s from the loaded profile, and on Save calls:

```dart
final res = await ref.read(doctorRepositoryProvider).updatePersonal(
  firstName: _first.text.trim(),
  middleName: _middle.text.trim().isEmpty ? null : _middle.text.trim(),
  lastName: _last.text.trim(),
  email: _email.text.trim().isEmpty ? null : _email.text.trim(),
);
res.fold(
  (f) => setState(() => _error = f.message),
  (_) async {
    await ref.read(profileControllerProvider.notifier).refresh();
    if (mounted) context.pop();
  },
);
```

Use `AppSpacing` padding, `AcuteButton` for Save, inline `errorText`.

- [ ] **Step 4: Run, then commit**

Run: `flutter test test/features/onboarding/personal_info_page_test.dart` → PASS.

```bash
git add lib/features/profile_setup/presentation/pages/sections/personal_info_page.dart test/features/onboarding/personal_info_page_test.dart
git commit -m "feat(app): add personal information form"
```

---

### Task F8: Education list + add/edit form (catalog picker with custom)

**Files:**
- Create: `acute-doctor/lib/features/profile_setup/presentation/pages/sections/education_page.dart`
- Create: `acute-doctor/lib/features/profile_setup/presentation/widgets/catalog_picker.dart`
- Test: `acute-doctor/test/features/onboarding/education_page_test.dart`

**Interfaces:**
- `CatalogPicker` — a reusable widget taking `Future<List<CatalogItem>> Function(String?) search` and `ValueChanged<String> onSelected`, allowing free-text custom entry (returns the typed string when no catalog match is chosen).
- `EducationPage` lists `profile.educations`, supports add (degree via `CatalogPicker` on `searchDegrees`, registration number required, optional institution/year), edit, delete; each mutation calls the repo then `profileController.refresh()`.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/onboarding/education_page_test.dart`:

```dart
import 'package:acute_doctor/core/errors/failures.dart';
import 'package:acute_doctor/features/onboarding/data/models/profile_models.dart';
import 'package:acute_doctor/features/onboarding/domain/doctor_repository.dart';
import 'package:acute_doctor/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:acute_doctor/features/profile_setup/presentation/pages/sections/education_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  testWidgets('lists existing educations', (tester) async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer((_) async => const Right(DoctorProfile(
          id: 'd', mobile: '91',
          educations: [Education(id: 'e1', degree: 'MBBS', registrationNumber: 'R1')],
        )));
    await tester.pumpWidget(ProviderScope(
      overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: EducationPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('MBBS'), findsOneWidget);
    expect(find.textContaining('R1'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/onboarding/education_page_test.dart` → FAIL.

- [ ] **Step 3: Implement `CatalogPicker`**

Create `catalog_picker.dart`: a field using Flutter's `Autocomplete<CatalogItem>` (or a `TextField` + suggestions list) that calls `search(query)` debounced, shows results, and on selection or free-text submit invokes `onSelected(value)`. Keep it presentational; the search function is injected.

- [ ] **Step 4: Implement `EducationPage`**

Create `education_page.dart`: watches `profileControllerProvider`; renders a `ListView` of `profile.educations` (degree + registration number, edit/delete actions) and an "Add education" button opening a bottom sheet/form. The form uses `CatalogPicker(search: (q) async => (await ref.read(doctorRepositoryProvider).searchDegrees(q)).getOrElse(() => []))`, a required registration-number `TextField`, optional institution and year. Save calls `addEducation(...)` (or `updateEducation(id, changes)`), then `profileController.refresh()`. Delete calls `deleteEducation(id)` then refresh.

- [ ] **Step 5: Run, generate if needed, commit**

Run: `flutter analyze && flutter test test/features/onboarding/education_page_test.dart` → clean + PASS.

```bash
git add lib/features/profile_setup/presentation/pages/sections/education_page.dart lib/features/profile_setup/presentation/widgets/catalog_picker.dart test/features/onboarding/education_page_test.dart
git commit -m "feat(app): add education section with catalog picker"
```

---

### Task F9: Speciality section

**Files:**
- Create: `acute-doctor/lib/features/profile_setup/presentation/pages/sections/speciality_page.dart`
- Test: `acute-doctor/test/features/onboarding/speciality_page_test.dart`

**Interfaces:**
- Lists `profile.specialities` as chips; add via `CatalogPicker` on `searchSpecialities` (custom allowed) → `addSpeciality(name)`; remove → `deleteSpeciality(id)`; refresh after each.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/onboarding/speciality_page_test.dart` mirroring F8's structure: mock `getMe` returning a profile with `specialities: [Speciality(id: 's1', name: 'Cardiology')]`, pump `SpecialityPage`, assert `find.text('Cardiology')` is found.

```dart
// (same imports as education_page_test, with SpecialityPage)
testWidgets('lists existing specialities', (tester) async {
  final repo = _MockRepo();
  when(repo.getMe).thenAnswer((_) async => const Right(DoctorProfile(
        id: 'd', mobile: '91',
        specialities: [Speciality(id: 's1', name: 'Cardiology')],
      )));
  await tester.pumpWidget(ProviderScope(
    overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(home: SpecialityPage()),
  ));
  await tester.pumpAndSettle();
  expect(find.text('Cardiology'), findsOneWidget);
});
```

- [ ] **Step 2: Run to verify it fails, implement, run to pass**

Run: `flutter test test/features/onboarding/speciality_page_test.dart` → FAIL, then implement `speciality_page.dart` (chips via `Wrap` + `Chip(onDeleted:)`, add button opens `CatalogPicker`), then PASS.

- [ ] **Step 3: Commit**

```bash
git add lib/features/profile_setup/presentation/pages/sections/speciality_page.dart test/features/onboarding/speciality_page_test.dart
git commit -m "feat(app): add speciality section"
```

---

### Task F10: Experience section with hospital search/add

**Files:**
- Create: `acute-doctor/lib/features/profile_setup/presentation/pages/sections/experience_page.dart`
- Create: `acute-doctor/lib/features/profile_setup/presentation/widgets/hospital_search_field.dart`
- Test: `acute-doctor/test/features/onboarding/experience_page_test.dart`

**Interfaces:**
- `HospitalSearchField` — searches `searchHospitals(q)`; when no match, offers "Add ‘<name>’ as a clinic/hospital" which calls `createHospital(...)` and returns the new `Hospital`. Emits the selected `Hospital`.
- `ExperiencePage` lists `profile.experiences` (hospital name, designation, current badge), add form (hospital via field, designation, start/end date pickers, `is_current` switch) → `addExperience(...)`; edit/delete; refresh after each.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/onboarding/experience_page_test.dart`: mock `getMe` returning a profile with one `Experience` whose `hospital` is `Hospital(id:'h1', name:'City Hospital', type:'hospital')`, pump `ExperiencePage`, assert `find.text('City Hospital')` is found.

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/onboarding/experience_page_test.dart` → FAIL.

- [ ] **Step 3: Implement `HospitalSearchField`**

Create `hospital_search_field.dart`: a search field that lists hospital results from the injected `search` callback; the trailing item is an "Add new" affordance that, when the query is non-empty and unmatched, calls an injected `onCreate(name, type)` returning the created `Hospital`, then emits it via `onSelected`.

- [ ] **Step 4: Implement `ExperiencePage`**

Create `experience_page.dart`: watches `profileControllerProvider`; lists experiences with edit/delete; add form wires `HospitalSearchField(search: (q) => repo.searchHospitals(q), onCreate: (n,t) => repo.createHospital(name:n, type:t))`. Dates use `showDatePicker` formatted as `yyyy-MM-dd` strings (the API contract); `is_current` is a `Switch`. Save → `addExperience(hospitalId:..., designation:..., startDate:..., isCurrent:...)`, then refresh.

- [ ] **Step 5: Analyze, run, commit**

Run: `flutter analyze && flutter test test/features/onboarding/experience_page_test.dart` → clean + PASS.

```bash
git add lib/features/profile_setup/presentation/pages/sections/experience_page.dart lib/features/profile_setup/presentation/widgets/hospital_search_field.dart test/features/onboarding/experience_page_test.dart
git commit -m "feat(app): add experience section with hospital search/add"
```

---

### Task F11: Working-hours editor

**Files:**
- Create: `acute-doctor/lib/features/profile_setup/presentation/pages/sections/working_hours_page.dart`
- Test: `acute-doctor/test/features/onboarding/working_hours_page_test.dart`

**Interfaces:**
- For each experience (hospital), shows day-of-week rows; the doctor adds one or more `{day_of_week, start_time, end_time}` slots → `addWorkingHour(experienceId:..., dayOfWeek:..., startTime:'HH:mm:ss', endTime:'HH:mm:ss')`; delete → `deleteWorkingHour(experienceId, wid)`; refresh after each.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/onboarding/working_hours_page_test.dart`: mock `getMe` returning a profile with one experience containing `workingHours: [WorkingHour(id:'w1', dayOfWeek:0, startTime:'09:00:00', endTime:'13:00:00')]`; pump `WorkingHoursPage`; assert a slot for Monday `09:00–13:00` is shown (assert `find.textContaining('09:00')`).

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/onboarding/working_hours_page_test.dart` → FAIL.

- [ ] **Step 3: Implement the page**

Create `working_hours_page.dart`: watches `profileControllerProvider`. If `profile.experiences` is empty, show an empty-state directing the doctor to add experience first. Otherwise, for each experience render the hospital name and its `workingHours` grouped by day (labels Mon–Sun from `dayOfWeek`), with delete buttons and an "Add slot" action opening day dropdown + two `showTimePicker`s. Format times to `HH:mm:ss`; validate end > start before calling `addWorkingHour`, then `profileController.refresh()`.

- [ ] **Step 4: Analyze, run, commit**

Run: `flutter analyze && flutter test test/features/onboarding/working_hours_page_test.dart` → clean + PASS.

```bash
git add lib/features/profile_setup/presentation/pages/sections/working_hours_page.dart test/features/onboarding/working_hours_page_test.dart
git commit -m "feat(app): add working-hours editor"
```

---

### Task F12: Full-suite verification

- [ ] **Step 1: Generate, analyze, and run everything**

Run:
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```
Expected: build_runner succeeds, `flutter analyze` reports no issues, all tests pass.

- [ ] **Step 2: Manual smoke (optional, requires backend running)**

With `acute-api` running (`uvicorn app.main:app --reload`) and a dev MSG91 widget configured, run the app, log in with a phone number, confirm a new number lands on the onboarding hub at 0%, fill a section, confirm the bar advances, and confirm "Continue to dashboard" reaches home. Re-login with the same number and confirm it routes to home when complete.

- [ ] **Step 3: Commit any generated artifacts**

```bash
git add -A
git commit -m "chore(app): regenerate codegen and verify onboarding suite"
```

---

## Self-Review Notes

- **Spec coverage:** session exchange + routing (F4, F5), hub + completion bar from backend (F6), personal info (F7), education with reg-no + catalog-or-custom (F8), speciality multiple + custom (F9), experience with shared hospital search/add (F10), working hours per hospital with multiple slots (F11), verification (F12). Networking/JWT plumbing (F1–F3). All spec sections map to a task.
- **Type consistency:** `DoctorRepository` method names defined in F3 are used verbatim in F4, F6–F11. `DoctorProfile.sections` (Map<String,bool>) keys (`personal/education/speciality/experience/working_hours`) align with the backend plan B4 and are mapped in the F6 hub. `LoginResponse.onboardingNeeded` set in F4 is read in F5's OTP routing.
- **Dependency note:** `mocktail` must be in `dev_dependencies` (add to `pubspec.yaml` if absent). `retrofit`/`retrofit_generator` and `freezed`/`json_serializable` are already used per the project codegen setup.
- **Cross-plan dependency:** This plan assumes the backend plan (`2026-06-28-doctor-onboarding-backend.md`) is implemented and reachable at `AppConfig.I.apiBaseUrl`.
