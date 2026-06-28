import 'package:flutter/material.dart';

import '../theme/tokens/tokens.dart';

/// Selectable card used in profile-setup style choices.
class AcuteSelectableCard extends StatelessWidget {
  const AcuteSelectableCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primaryTeal : AppColors.hairline;
    final iconBg = selected ? AppColors.primaryTeal : AppColors.surfaceMuted;
    final iconColor = selected ? Colors.white : AppColors.ink;

    return Material(
      color: selected ? AppColors.softTeal.withValues(alpha: 0.5) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.brLg,
        side: BorderSide(color: borderColor, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg, borderRadius: AppRadii.brMd),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyStrong),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.body.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.primaryTeal : AppColors.hairline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
