import 'package:acutework/features/onboarding/data/models/profile_models.dart';
import 'package:acutework/features/onboarding/domain/doctor_repository.dart';
import 'package:acutework/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  test('profileController loads profile from repository', () async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer(
      (_) async => const Right(
        DoctorProfile(
          id: 'd1',
          mobile: '91',
          profileCompletion: 20,
          sections: {'personal': true},
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        doctorRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final profile = await container.read(profileControllerProvider.future);
    expect(profile.profileCompletion, 20);
  });
}
