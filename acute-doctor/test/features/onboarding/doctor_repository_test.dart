import 'package:acutework/core/errors/exceptions.dart';
import 'package:acutework/core/errors/failures.dart';
import 'package:acutework/features/onboarding/data/doctor_api.dart';
import 'package:acutework/features/onboarding/data/doctor_repository_impl.dart';
import 'package:acutework/features/onboarding/data/models/login_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements DoctorApi {}

void main() {
  setUpAll(() => registerFallbackValue(const LoginRequest(accessToken: 'x')));

  test('login success returns Right(LoginResponse)', () async {
    final api = _MockApi();
    when(() => api.login(any())).thenAnswer(
      (_) async => const LoginResponse(
        token: 'jwt', isNew: true, onboardingNeeded: true, profileCompletion: 0,
      ),
    );
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
