import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/tokens/tokens.dart';
import '../../../../core/widgets/acute_button.dart';
import '../../../onboarding/data/models/profile_models.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';

// Maps (sectionKey, label, icon, route) for the five onboarding sections.
// Backend section keys must match exactly: personal, education, speciality,
// experience, working_hours.
const _sections = <(String, String, IconData, String)>[
  (
    'personal',
    'Personal information',
    Icons.person_outline,
    AppRoutes.onboardingPersonal,
  ),
  (
    'education',
    'Education & registration',
    Icons.school_outlined,
    AppRoutes.onboardingEducation,
  ),
  (
    'speciality',
    'Specialities',
    Icons.medical_services_outlined,
    AppRoutes.onboardingSpeciality,
  ),
  (
    'experience',
    'Experience',
    Icons.work_outline,
    AppRoutes.onboardingExperience,
  ),
  (
    'working_hours',
    'Working hours',
    Icons.schedule_outlined,
    AppRoutes.onboardingWorkingHours,
  ),
];

/// Hub page shown after login, listing all five onboarding sections with their
/// completion state and an overall progress bar.
class OnboardingHubPage extends ConsumerWidget {
  const OnboardingHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.clinicalWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Complete your profile',
          style: AppTypography.bodyStrong.copyWith(color: AppColors.ink),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load profile: $e',
                style: AppTypography.body.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AcuteButton(
                label: 'Retry',
                expand: false,
                onPressed: () =>
                    ref.read(profileControllerProvider.notifier).refresh(),
              ),
            ],
          ),
        ),
        data: (profile) => _HubBody(profile: profile),
      ),
    );
  }
}

class _HubBody extends ConsumerWidget {
  const _HubBody({required this.profile});

  final DoctorProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = profile.profileCompletion;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Progress header
                _ProgressHeader(completion: completion),
                const SizedBox(height: AppSpacing.xxl),
                // Section tiles
                ...List.generate(_sections.length, (i) {
                  final (key, label, icon, route) = _sections[i];
                  final done = profile.sections[key] == true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _SectionTile(
                      label: label,
                      icon: icon,
                      done: done,
                      onTap: () async {
                        await context.push(route);
                        // Refresh profile after returning from a section page.
                        await ref
                            .read(profileControllerProvider.notifier)
                            .refresh();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          // Persistent bottom action
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: AcuteButton(
              label: 'Continue to dashboard',
              onPressed: () => context.go(AppRoutes.home),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.completion});

  final int completion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile completion',
              style: AppTypography.bodyStrong.copyWith(color: AppColors.ink),
            ),
            Text(
              '$completion% complete',
              style:
                  AppTypography.caption.copyWith(color: AppColors.primaryTeal),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadii.brPill,
          child: LinearProgressIndicator(
            value: completion / 100,
            minHeight: 8,
            backgroundColor: AppColors.hairline,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
          ),
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.label,
    required this.icon,
    required this.done,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.brMd,
        side: BorderSide(color: AppColors.hairline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primaryTeal),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style:
                      AppTypography.bodyStrong.copyWith(color: AppColors.ink),
                ),
              ),
              if (done)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.safeGreen,
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
