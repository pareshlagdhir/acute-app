import 'package:flutter/material.dart';

import '../theme/tokens/tokens.dart';

enum AcuteButtonVariant { primary, emergency, markSafe, secondary, soft, ghost }

/// Branded button that mirrors the Acutework component spec.
class AcuteButton extends StatelessWidget {
  const AcuteButton({
    required this.label,
    required this.onPressed,
    this.variant = AcuteButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AcuteButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final styling = _styleFor(variant);
    final disabled = onPressed == null || loading;

    final child = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: styling.foreground),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: AppTypography.button.copyWith(color: styling.foreground)),
            ],
          );

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: styling.background,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brLg,
          side: styling.border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: AppRadii.brLg,
          child: Container(
            constraints: BoxConstraints(minHeight: 56, minWidth: expand ? double.infinity : 0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }

  _ButtonStyling _styleFor(AcuteButtonVariant v) {
    switch (v) {
      case AcuteButtonVariant.primary:
        return const _ButtonStyling(AppColors.primaryTeal, Colors.white);
      case AcuteButtonVariant.emergency:
        return const _ButtonStyling(AppColors.emergencyRed, Colors.white);
      case AcuteButtonVariant.markSafe:
        return const _ButtonStyling(AppColors.safeGreen, Colors.white);
      case AcuteButtonVariant.secondary:
        return const _ButtonStyling(
          Colors.white,
          AppColors.ink,
          border: BorderSide(color: AppColors.hairline),
        );
      case AcuteButtonVariant.soft:
        return const _ButtonStyling(AppColors.softTeal, AppColors.deepTeal);
      case AcuteButtonVariant.ghost:
        return const _ButtonStyling(Colors.transparent, AppColors.primaryTeal);
    }
  }
}

class _ButtonStyling {
  const _ButtonStyling(this.background, this.foreground, {this.border});
  final Color background;
  final Color foreground;
  final BorderSide? border;
}
