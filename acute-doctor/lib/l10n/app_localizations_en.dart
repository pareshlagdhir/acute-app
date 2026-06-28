// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Acutework';

  @override
  String get tagline => 'Safety alerts for medical practitioners';

  @override
  String get verifiedBy => 'Verified for IMA & state councils';

  @override
  String get ctaSendCode => 'Send code';

  @override
  String get ctaVerifyAndContinue => 'Verify and continue';

  @override
  String get ctaContinue => 'Continue';

  @override
  String get ctaEmergency => 'Emergency';

  @override
  String get ctaMarkSafe => 'Mark safe';
}
