import 'package:acutework/core/errors/failures.dart';
import 'package:acutework/features/onboarding/data/models/profile_models.dart';
import 'package:acutework/features/onboarding/domain/doctor_repository.dart';
import 'package:acutework/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:acutework/features/profile_setup/presentation/pages/sections/personal_info_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  testWidgets('renders name fields prefilled', (tester) async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer(
      (_) async => const Right(
        DoctorProfile(id: 'd', mobile: '91', firstName: 'Asha', lastName: 'Rao'),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: PersonalInfoPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('Rao'), findsOneWidget);
  });

  testWidgets('shows inline error when updatePersonal fails', (tester) async {
    final repo = _MockRepo();
    when(repo.getMe).thenAnswer(
      (_) async => const Right(
        DoctorProfile(id: 'd', mobile: '91', firstName: 'Asha', lastName: 'Rao'),
      ),
    );
    when(
      () => repo.updatePersonal(
        firstName: any(named: 'firstName'),
        middleName: any(named: 'middleName'),
        lastName: any(named: 'lastName'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [doctorRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: PersonalInfoPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Server error'), findsOneWidget);
  });
}
