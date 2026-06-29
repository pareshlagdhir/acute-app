import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/tokens/tokens.dart';
import '../widgets/radial_pulse.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    // Seed authTokenProvider from secure storage before deciding where to go.
    final storedToken =
        await ref.read(secureStorageProvider).readAuthToken();
    ref.read(authTokenProvider.notifier).token = storedToken;

    // Wait for the splash animation to complete (approx 2200 ms).
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;
    if (storedToken != null && storedToken.isNotEmpty) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Expanded(child: Center(child: RadialPulse())),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  0,
                  AppSpacing.xxl,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  children: [
                    Text(
                      AppConstants.appName,
                      style: AppTypography.display.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppConstants.tagline,
                      style: AppTypography.body.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: AppRadii.brPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            AppConstants.verifiedBy,
                            style: AppTypography.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
