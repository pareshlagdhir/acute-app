import 'package:acutework/features/onboarding/data/models/login_models.dart';
import 'package:acutework/features/onboarding/domain/doctor_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  test('login exchange returns onboardingNeeded flag', () async {
    final repo = _MockRepo();
    when(() => repo.login('tok')).thenAnswer(
      (_) async => const Right(
        LoginResponse(
          token: 'jwt',
          isNew: true,
          onboardingNeeded: true,
          profileCompletion: 0,
        ),
      ),
    );
    final res = await repo.login('tok');
    res.fold((_) => fail('expected Right'), (r) {
      expect(r.token, 'jwt');
      expect(r.onboardingNeeded, true);
    });
  });
}
