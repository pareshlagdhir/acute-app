import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/tokens/tokens.dart';
import '../../../../core/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acutework'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        children: [
          const Row(
            children: [
              AcuteBadge(
                label: 'Verified',
                variant: AcuteBadgeVariant.verified,
                icon: Icons.check_circle,
              ),
              SizedBox(width: AppSpacing.sm),
              AcuteBadge(label: 'Marked safe', variant: AcuteBadgeVariant.markedSafe),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('You are protected.', style: AppTypography.display),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap the emergency button to alert your responders within 3 seconds.',
            style: AppTypography.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AcuteButton(
            label: 'Emergency',
            variant: AcuteButtonVariant.emergency,
            icon: Icons.emergency_outlined,
            onPressed: () => context.push(AppRoutes.alerts),
          ),
          const SizedBox(height: AppSpacing.md),
          AcuteButton(
            label: 'Mark safe',
            variant: AcuteButtonVariant.markSafe,
            icon: Icons.shield_outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
