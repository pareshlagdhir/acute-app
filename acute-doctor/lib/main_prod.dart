import 'bootstrap.dart';
import 'core/config/app_config.dart';

Future<void> main() => bootstrap(
      flavor: Flavor.prod,
      apiBaseUrl: 'https://api.acutework.in',
      enableLogging: false,
    );
