import 'package:acutework/core/config/app_config.dart';
import 'package:acutework/core/network/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    AppConfig.init(
      flavor: Flavor.dev,
      appName: 'test',
      apiBaseUrl: 'http://localhost:8000',
    );
  });

  test('dioProvider builds a Dio with base options', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final dio = container.read(dioProvider);
    expect(dio, isA<Dio>());
  });
}
