import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/secure_storage.dart';
import 'dio_client.dart';

final secureStorageProvider = Provider<SecureStorage>(
  (ref) => SecureStorage(const FlutterSecureStorage()),
);

/// Notifier holding the in-memory cached JWT token.
/// Seeded from secure storage at app start (see router bootstrap).
class AuthTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  String? get token => state;
  set token(String? value) => state = value;
}

/// In-memory cache of the JWT so the Dio interceptor reads it synchronously.
final authTokenProvider =
    NotifierProvider<AuthTokenNotifier, String?>(AuthTokenNotifier.new);

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(tokenProvider: () => ref.read(authTokenProvider));
});
