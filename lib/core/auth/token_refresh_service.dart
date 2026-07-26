import 'package:dio/dio.dart';
import 'package:tisini/core/auth/user_session_prefs.dart';
import 'package:tisini/core/constants/api_constants.dart';
import 'package:tisini/core/services/auth_token_storage.dart';
import 'package:tisini/core/services/http_response_body.dart';

/// Shared refresh-token HTTP call.
///
/// Used by [HttpService] (401 retry) and [SessionService] (cold-start restore).
abstract final class TokenRefreshService {
  TokenRefreshService._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.apiURL,
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  /// Returns `true` when new tokens were saved to [AuthTokenStorage].
  static Future<bool> refresh({String? refreshToken}) async {
    final refresh = refreshToken ?? AuthTokenStorage.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: {'refresh_token': refresh},
      );

      HttpResponseBody.throwIfHttpError(
        response,
        fallback: 'Session refresh failed',
      );

      final data = HttpResponseBody.requireMap(response);
      final access = data['access_token']?.toString() ?? '';
      final newRefresh = data['refresh_token']?.toString() ?? '';

      if (access.isEmpty) return false;

      await AuthTokenStorage.saveTokens(
        accessToken: access,
        refreshToken: newRefresh.isNotEmpty ? newRefresh : refresh,
        persistRefreshForRememberMe: UserSessionPrefs.rememberMe,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
