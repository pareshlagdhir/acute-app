import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage(this._storage);
  final FlutterSecureStorage _storage;

  static const _kAuthToken = 'auth_token';
  static const _kRefreshToken = 'refresh_token';

  Future<void> writeAuthToken(String token) =>
      _storage.write(key: _kAuthToken, value: token);

  Future<String?> readAuthToken() => _storage.read(key: _kAuthToken);

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> clear() => _storage.deleteAll();
}
