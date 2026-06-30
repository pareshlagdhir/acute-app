enum Flavor { dev, staging, prod }

/// Compile-time configuration injected via `main_<flavor>.dart`.
class AppConfig {
  AppConfig._({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.apiTimeoutMs,
    required this.enableLogging,
    required this.defaultCountryCode,
  });

  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;
  final int apiTimeoutMs;
  final bool enableLogging;

  /// E.164 country code without `+`, e.g. `91` for India. Prepended to the
  /// user-entered 10-digit number when calling the backend OTP API.
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
    String defaultCountryCode = '91',
  }) {
    _instance = AppConfig._(
      flavor: flavor,
      appName: appName,
      apiBaseUrl: apiBaseUrl,
      apiTimeoutMs: apiTimeoutMs,
      enableLogging: enableLogging,
      defaultCountryCode: defaultCountryCode,
    );
  }

  bool get isProd => flavor == Flavor.prod;
}
