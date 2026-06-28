import 'bootstrap.dart';
import 'core/config/app_config.dart';

const _msg91WidgetId = String.fromEnvironment('MSG91_WIDGET_ID');
const _msg91TokenAuth = String.fromEnvironment('MSG91_TOKEN_AUTH');

Future<void> main() => bootstrap(
      flavor: Flavor.staging,
      apiBaseUrl: 'https://api-staging.acutework.in',
      enableLogging: true,
      msg91WidgetId: _msg91WidgetId,
      msg91TokenAuth: _msg91TokenAuth,
    );
