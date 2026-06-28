enum Flavor { dev, staging, prod }

/// Compile-time configuration injected via `main_<flavor>.dart`.
class AppConfig {
  AppConfig._({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.apiTimeoutMs,
    required this.enableLogging,
    required this.msg91WidgetId,
    required this.msg91TokenAuth,
    required this.defaultCountryCode,
  });

  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;
  final int apiTimeoutMs;
  final bool enableLogging;

  /// MSG91 OTP Widget credentials. The pair is designed for client embedding
  /// (Web/WebView) and is less sensitive than the dashboard Auth Key — still,
  /// inject via `--dart-define-from-file=env/<flavor>.json` (gitignored) so
  /// they don't land in VCS or analytics dumps.
  final String msg91WidgetId;
  final String msg91TokenAuth;

  /// E.164 country code without `+`, e.g. `91` for India. Prepended to the
  /// user-entered 10-digit number when calling the widget.
  final String defaultCountryCode;

  static AppConfig? _instance;
  static AppConfig get I {
    final i = _instance;
    if (i == null) {
      throw StateError('AppConfig not initialized. Call AppConfig.init() in main.');
    }
    return i;
  }

  static void init({
    required Flavor flavor,
    required String appName,
    required String apiBaseUrl,
    int apiTimeoutMs = 20000,
    bool enableLogging = false,
    String msg91WidgetId = '',
    String msg91TokenAuth = '',
    String defaultCountryCode = '91',
  }) {
    _instance = AppConfig._(
      flavor: flavor,
      appName: appName,
      apiBaseUrl: apiBaseUrl,
      apiTimeoutMs: apiTimeoutMs,
      enableLogging: enableLogging,
      msg91WidgetId: msg91WidgetId,
      msg91TokenAuth: msg91TokenAuth,
      defaultCountryCode: defaultCountryCode,
    );
  }

  bool get isProd => flavor == Flavor.prod;
}
