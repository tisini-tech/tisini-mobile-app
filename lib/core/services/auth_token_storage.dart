import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/core/auth/secure_session_store.dart';
import 'package:tisini/core/auth/user_session_prefs.dart';

/// Token cache + facade for the HTTP layer.
///
/// - Secrets live in [SecureSessionStore].
/// - Legacy `GetStorage` keys are synced for older controllers still calling
///   `box.read('token')`; prefer [accessToken] for new code.
class AuthTokenStorage {
  AuthTokenStorage._();

  static final GetStorage _box = GetStorage();

  static const _legacyAccessKey = 'token';
  static const _legacyRefreshKey = 'refresh_token';

  static String? _accessTokenCache;
  static String? _refreshTokenCache;
  static bool _initialized = false;

  static String? get accessToken {
    final cached = _accessTokenCache;
    if (cached != null && cached.isNotEmpty) return cached;

    final legacy = _box.read(_legacyAccessKey);
    return legacy is String && legacy.isNotEmpty ? legacy : null;
  }

  static String? get refreshToken {
    final cached = _refreshTokenCache;
    if (cached != null && cached.isNotEmpty) return cached;

    final legacy = _box.read(_legacyRefreshKey);
    return legacy is String && legacy.isNotEmpty ? legacy : null;
  }

  static bool get hasSession {
    final token = accessToken;
    return token != null && token.isNotEmpty;
  }

  /// Load secure storage into memory (call once from `main()`).
  static Future<void> initialize() async {
    if (_initialized) return;

    _accessTokenCache = await SecureSessionStore.readAccessToken();
    _refreshTokenCache = await SecureSessionStore.readRefreshToken();

    await _migrateLegacyTokensIfNeeded();
    _initialized = true;
  }

  static Future<void> _migrateLegacyTokensIfNeeded() async {
    final legacyAccess = _box.read(_legacyAccessKey);
    if ((_accessTokenCache == null || _accessTokenCache!.isEmpty) &&
        legacyAccess is String &&
        legacyAccess.isNotEmpty) {
      _accessTokenCache = legacyAccess;
      await SecureSessionStore.writeAccessToken(legacyAccess);
    }

    final legacyRefresh = _box.read(_legacyRefreshKey);
    if ((_refreshTokenCache == null || _refreshTokenCache!.isEmpty) &&
        legacyRefresh is String &&
        legacyRefresh.isNotEmpty &&
        UserSessionPrefs.rememberMe) {
      _refreshTokenCache = legacyRefresh;
      await SecureSessionStore.writeRefreshToken(legacyRefresh);
    }
  }

  /// [persistRefreshForRememberMe]: when false, refresh stays in memory only
  /// for the current app session (not written to secure storage).
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required bool persistRefreshForRememberMe,
  }) async {
    _accessTokenCache = accessToken;
    _refreshTokenCache = refreshToken;

    await SecureSessionStore.writeAccessToken(accessToken);
    if (persistRefreshForRememberMe) {
      await SecureSessionStore.writeRefreshToken(refreshToken);
    } else {
      await SecureSessionStore.deleteRefreshToken();
    }

    // Legacy sync for controllers not yet migrated to this facade.
    await _box.write(_legacyAccessKey, accessToken);
    await _box.write(_legacyRefreshKey, refreshToken);
  }

  static Future<void> clear() async {
    _accessTokenCache = null;
    _refreshTokenCache = null;
    await SecureSessionStore.deleteAll();
    await _box.remove(_legacyAccessKey);
    await _box.remove(_legacyRefreshKey);
  }

  static void redirectToLogin() {
    if (Get.currentRoute == '/login') return;
    Get.offAllNamed('/login');
  }
}
