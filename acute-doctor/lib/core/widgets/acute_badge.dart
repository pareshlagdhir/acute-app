import 'package:flutter/material.dart';

import '../theme/tokens/tokens.dart';

enum AcuteBadgeVariant { verified, markedSafe, setupNeeded, activeAlert, sms }

/// Pill-shaped status badge per design system.
class AcuteBadge extends StatelessWidget {
  const AcuteBadge({
    required this.label,
    required this.variant,
    this.icon,
    super.key,
  });

  final String label;
  final AcuteBadgeVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final styling = _styleFor(variant);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: styling.background,
        borderRadius: AppRadii.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: styling.foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: styling.foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeStyling _styleFor(AcuteBadgeVariant v) {
    switch (v) {
      case AcuteBadgeVariant.verified:
        return const _BadgeStyling(AppColors.verifiedBg, AppColors.deepTeal);
      case AcuteBadgeVariant.markedSafe:
        return const _BadgeStyling(AppColors.markedSafeBg, AppColors.safeGreen);
      case AcuteBadgeVariant.setupNeeded:
        return const _BadgeStyling(AppColors.setupNeededBg, Color(0xFF8A5A14));
      case AcuteBadgeVariant.activeAlert:
        return const _BadgeStyling(AppColors.activeAlertBg, AppColors.emergencyRed);
      case AcuteBadgeVariant.sms:
        return const _BadgeStyling(AppColors.smsBg, AppColors.ink);
    }
  }
}

class _BadgeStyling {
  const _BadgeStyling(this.background, this.foreground);
  final Color background;
  final Color foreground;
}
