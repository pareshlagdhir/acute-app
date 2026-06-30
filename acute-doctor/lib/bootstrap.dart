import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/storage/hive_boxes.dart';

/// Shared bootstrap invoked from each flavor entrypoint.
Future<void> bootstrap({
  required Flavor flavor,
  required String apiBaseUrl,
  required bool enableLogging,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(
    flavor: flavor,
    appName: 'Acutework',
    apiBaseUrl: apiBaseUrl,
    enableLogging: enableLogging,
  );

  await HiveBoxes.initAll();

  runApp(const ProviderScope(child: AcuteworkApp()));
}
