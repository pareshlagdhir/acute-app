import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile_setup/presentation/pages/onboarding_hub_page.dart';
import '../../features/profile_setup/presentation/pages/sections/education_page.dart';
import '../../features/profile_setup/presentation/pages/sections/personal_info_page.dart';
import '../../features/profile_setup/presentation/pages/sections/experience_page.dart';
import '../../features/profile_setup/presentation/pages/sections/speciality_page.dart';
import '../../features/profile_setup/presentation/pages/sections/working_hours_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../network/dio_provider.dart';
import 'app_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
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
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, state) => OtpPage(
          mobile: state.uri.queryParameters['mobile'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const OnboardingHubPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPersonal,
        builder: (_, __) => const PersonalInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingEducation,
        builder: (_, __) => const EducationPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSpeciality,
        builder: (_, __) => const SpecialityPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingExperience,
        builder: (_, __) => const ExperiencePage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingWorkingHours,
        builder: (_, __) => const WorkingHoursPage(),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
      GoRoute(path: AppRoutes.alerts, builder: (_, __) => const AlertsPage()),
      GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfilePage()),
    ],
  );
});
