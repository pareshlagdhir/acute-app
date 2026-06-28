import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/storage/hive_boxes.dart';

/// Shared bootstrap invoked from each flavor entrypoint.
Future<void> bootstrap({
  required Flavor flavor,
  required String apiBaseUrl,
  required bool enableLogging,
  String msg91WidgetId = '',
  String msg91TokenAuth = '',
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(
    flavor: flavor,
    appName: 'Acutework',
    apiBaseUrl: apiBaseUrl,
    enableLogging: enableLogging,
    msg91WidgetId: msg91WidgetId,
    msg91TokenAuth: msg91TokenAuth,
  );

  if (msg91WidgetId.isNotEmpty && msg91TokenAuth.isNotEmpty) {
    OTPWidget.initializeWidget(msg91WidgetId, msg91TokenAuth);
  }

  await HiveBoxes.initAll();

  runApp(const ProviderScope(child: AcuteworkApp()));
}
