import 'bootstrap.dart';
import 'core/config/app_config.dart';

const _msg91WidgetId = String.fromEnvironment('MSG91_WIDGET_ID');
const _msg91TokenAuth = String.fromEnvironment('MSG91_TOKEN_AUTH');

Future<void> main() => bootstrap(
      flavor: Flavor.prod,
      apiBaseUrl: 'https://api.acutework.in',
      enableLogging: false,
      msg91WidgetId: _msg91WidgetId,
      msg91TokenAuth: _msg91TokenAuth,
    );
