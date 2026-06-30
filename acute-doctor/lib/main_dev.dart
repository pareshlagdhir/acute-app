import 'bootstrap.dart';
import 'core/config/app_config.dart';

Future<void> main() => bootstrap(
      flavor: Flavor.dev,
      apiBaseUrl: 'http://localhost:8000',
      enableLogging: true,
    );
