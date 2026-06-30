import 'bootstrap.dart';
import 'core/config/app_config.dart';

Future<void> main() => bootstrap(
      flavor: Flavor.staging,
      apiBaseUrl: 'https://api-staging.acutework.in',
      enableLogging: true,
    );
