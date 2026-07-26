import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted token vault (iOS Keychain / Android EncryptedSharedPreferences).
///
/// Only [SessionService] and [AuthTokenStorage] should use this directly.
abstract final class SecureSessionStore {
  SecureSessionStore._();

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  static Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  static Future<void> writeAccessToken(String value) =>
      _storage.write(key: _accessKey, value: value);

  static Future<void> writeRefreshToken(String value) =>
      _storage.write(key: _refreshKey, value: value);

  static Future<void> deleteAccessToken() => _storage.delete(key: _accessKey);

  static Future<void> deleteRefreshToken() => _storage.delete(key: _refreshKey);

  static Future<void> deleteAll() => _storage.deleteAll();
}
