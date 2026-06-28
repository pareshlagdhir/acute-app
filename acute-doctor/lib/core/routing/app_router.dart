import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile_setup/presentation/pages/profile_setup_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
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
        builder: (_, __) => const ProfileSetupPage(),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
      GoRoute(path: AppRoutes.alerts, builder: (_, __) => const AlertsPage()),
      GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfilePage()),
    ],
  );
});
