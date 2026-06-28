import 'package:acutework/features/onboarding/data/models/profile_models.dart';
import 'package:acutework/features/onboarding/domain/doctor_repository.dart';
import 'package:acutework/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:acutework/features/profile_setup/presentation/pages/sections/education_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  testWidgets('lists existing educations', (tester) async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer(
      (_) async => const Right(
        DoctorProfile(
          id: 'd',
          mobile: '91',
          educations: [
            Education(id: 'e1', degree: 'MBBS', registrationNumber: 'R1'),
          ],
        ),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: EducationPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('MBBS'), findsOneWidget);
    expect(find.textContaining('R1'), findsOneWidget);
  });
}
