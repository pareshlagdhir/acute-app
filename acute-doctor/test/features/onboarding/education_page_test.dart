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

  testWidgets('add flow: calls addEducation and closes sheet on success',
      (tester) async {
    final repo = _MockRepo();

    // First getMe returns empty profile (no educations yet).
    // Second getMe (after refresh) returns the profile with the new education.
    var getMeCallCount = 0;
    when(repo.getMe).thenAnswer((_) async {
      getMeCallCount++;
      if (getMeCallCount == 1) {
        return const Right(DoctorProfile(id: 'd', mobile: '91'));
      }
      return const Right(
        DoctorProfile(
          id: 'd',
          mobile: '91',
          educations: [
            Education(id: 'e1', degree: 'MBBS', registrationNumber: 'R123'),
          ],
        ),
      );
    });

    when(
      () => repo.addEducation(
        degree: any(named: 'degree'),
        registrationNumber: any(named: 'registrationNumber'),
        institution: any(named: 'institution'),
        yearOfCompletion: any(named: 'yearOfCompletion'),
      ),
    ).thenAnswer(
      (_) async => const Right(
        Education(id: 'e1', degree: 'MBBS', registrationNumber: 'E123'),
      ),
    );

    // searchDegrees is called by CatalogPicker but we return empty list so the
    // user's typed value is used as a custom entry on submit.
    when(() => repo.searchDegrees(any())).thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: EducationPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Open the add form sheet.
    await tester.tap(find.text('Add education'));
    await tester.pumpAndSettle();

    // Fill in Degree via CatalogPicker — type and submit to trigger onSelected.
    final degreeField = find.widgetWithText(TextField, 'Degree *');
    await tester.tap(degreeField);
    await tester.enterText(degreeField, 'MBBS');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Fill in registration number.
    final regField = find.widgetWithText(TextField, 'Registration number *');
    await tester.enterText(regField, 'E123');
    await tester.pumpAndSettle();

    // Tap Save.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify addEducation was called with the expected arguments.
    verify(
      () => repo.addEducation(
        degree: 'MBBS',
        registrationNumber: 'E123',
        institution: null,
        yearOfCompletion: null,
      ),
    ).called(1);

    // Sheet should have closed; the "Add education" button is back in view.
    expect(find.text('Add education'), findsOneWidget);
  });
}
