import 'package:acutework/features/onboarding/data/models/profile_models.dart';
import 'package:acutework/features/onboarding/domain/doctor_repository.dart';
import 'package:acutework/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:acutework/features/profile_setup/presentation/pages/sections/speciality_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  testWidgets('lists existing specialities', (tester) async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer(
      (_) async => const Right(
        DoctorProfile(
          id: 'd',
          mobile: '91',
          specialities: [Speciality(id: 's1', name: 'Cardiology')],
        ),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: SpecialityPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cardiology'), findsOneWidget);
  });
}
