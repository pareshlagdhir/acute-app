import 'package:hive_flutter/hive_flutter.dart';

/// Centralised Hive box names + initializer.
abstract final class HiveBoxes {
  static const String session = 'session_box';
  static const String settings = 'settings_box';
  static const String alertsCache = 'alerts_cache_box';

  static Future<void> initAll() async {
    await Hive.initFlutter();
    // Register adapters here once generated, e.g.:
    // Hive.registerAdapter(UserModelAdapter());
    await Future.wait([
      Hive.openBox<dynamic>(session),
      Hive.openBox<dynamic>(settings),
      Hive.openBox<dynamic>(alertsCache),
    ]);
  }
}
