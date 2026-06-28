import 'package:acutework/core/routing/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding section routes are under /onboarding', () {
    expect(AppRoutes.onboardingPersonal, '/onboarding/personal');
    expect(AppRoutes.onboardingWorkingHours, '/onboarding/working-hours');
  });

  test('all onboarding section route constants exist', () {
    expect(AppRoutes.onboardingPersonal, '/onboarding/personal');
    expect(AppRoutes.onboardingEducation, '/onboarding/education');
    expect(AppRoutes.onboardingSpeciality, '/onboarding/speciality');
    expect(AppRoutes.onboardingExperience, '/onboarding/experience');
    expect(AppRoutes.onboardingWorkingHours, '/onboarding/working-hours');
  });
}
