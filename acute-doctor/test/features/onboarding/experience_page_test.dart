import 'package:acutework/features/onboarding/data/models/profile_models.dart';
import 'package:acutework/features/onboarding/domain/doctor_repository.dart';
import 'package:acutework/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:acutework/features/profile_setup/presentation/pages/sections/experience_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  testWidgets('lists existing experience with hospital name', (tester) async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer(
      (_) async => const Right(
        DoctorProfile(
          id: 'd',
          mobile: '91',
          experiences: [
            Experience(
              id: 'e1',
              hospital: Hospital(id: 'h1', name: 'City Hospital', type: 'hospital'),
              designation: 'Cardiologist',
              isCurrent: true,
            ),
          ],
        ),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: ExperiencePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('City Hospital'), findsOneWidget);
  });
}
