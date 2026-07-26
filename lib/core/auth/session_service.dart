import 'package:get/get.dart';
import 'package:tisini/core/auth/token_refresh_service.dart';
import 'package:tisini/core/auth/user_session_prefs.dart';
import 'package:tisini/core/services/auth_token_storage.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';

/// Whether a cold-start session restore succeeded.
enum SessionRestoreResult { authenticated, unauthenticated }

/// Application-layer session orchestration.
///
/// See [SESSION_ARCHITECTURE.md] for the full design.
class SessionService extends GetxService {
  static SessionService get instance => Get.find<SessionService>();

  /// Called when the login screen opens (cold start or manual navigation).
  Future<SessionRestoreResult> tryRestoreSession() async {
    await AuthTokenStorage.initialize();

    if (!UserSessionPrefs.rememberMe) {
      await AuthTokenStorage.clear();
      return SessionRestoreResult.unauthenticated;
    }

    final refreshed = await TokenRefreshService.refresh();
    if (refreshed) {
      return SessionRestoreResult.authenticated;
    }

    await clearSession(clearRememberMe: false);
    return SessionRestoreResult.unauthenticated;
  }

  /// After a successful login or account verification.
  Future<void> persistLogin({
    required User user,
    required String loginId,
    required bool rememberMe,
  }) async {
    await UserSessionPrefs.setRememberMe(rememberMe);
    if (rememberMe) {
      await UserSessionPrefs.setRememberedLoginId(loginId);
    } else {
      await UserSessionPrefs.clearRememberedLoginId();
    }

    await AuthTokenStorage.saveTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
      persistRefreshForRememberMe: rememberMe,
    );
    await UserSessionPrefs.saveUserProfile(user);
  }

  /// Logout or forced sign-out. Tokens are always removed.
  Future<void> clearSession({
    bool clearRememberMe = false,
    bool clearProfile = true,
  }) async {
    await AuthTokenStorage.clear();
    if (clearProfile) {
      await UserSessionPrefs.clearProfile();
    }
    if (clearRememberMe) {
      await UserSessionPrefs.clearRememberMeSettings();
    }
  }

  /// Prefills the login form from non-sensitive prefs.
  void applyRememberMeToForm({
    required void Function(bool rememberMe) setRememberMe,
    required void Function(String loginId) setLoginId,
  }) {
    setRememberMe(UserSessionPrefs.rememberMe);
    final id = UserSessionPrefs.rememberedLoginId;
    if (id != null) {
      setLoginId(id);
    }
  }
}
