import 'package:flutter/material.dart';

/// Acutework color palette.
///
/// `deep teal + clinical white` — Material 3 + iOS-sensitive.
/// Red is reserved for emergency actions ONLY — never decorative.
abstract final class AppColors {
  // Brand
  static const Color primaryTeal = Color(0xFF0F766E); // Trust, default
  static const Color deepTeal = Color(0xFF0A4F4A); // Hero gradients
  static const Color softTeal = Color(0xFFD7EDEA); // Soft button bg

  // Semantic
  static const Color safeGreen = Color(0xFF4F9A6B); // Mark safe / OK
  static const Color warnAmber = Color(0xFFE5A24B); // Setup needed
  static const Color emergencyRed = Color(0xFFE5414B); // Alert action ONLY

  // Neutral
  static const Color ink = Color(0xFF0B1416); // Body text
  static const Color muted = Color(0xFF6B7280); // Secondary text
  static const Color hairline = Color(0xFFE5E7EB); // Borders
  static const Color clinicalWhite = Color(0xFFFAFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F5F2);

  // Status background tints (badges)
  static const Color verifiedBg = Color(0xFFD7EDEA);
  static const Color markedSafeBg = Color(0xFFDCEFE2);
  static const Color setupNeededBg = Color(0xFFFBEBCB);
  static const Color activeAlertBg = Color(0xFFFAD7DA);
  static const Color smsBg = Color(0xFFEDEFEC);

  // Hero gradient (splash)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F766E), Color(0xFF0A4F4A)],
  );
}
