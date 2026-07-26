import 'package:get_storage/get_storage.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';

/// Non-sensitive session preferences (GetStorage).
///
/// Never store passwords or tokens here.
abstract final class UserSessionPrefs {
  UserSessionPrefs._();

  static final GetStorage _box = GetStorage();

  static const _rememberMeKey = 'remember_me';
  static const _rememberedLoginIdKey = 'remembered_login_id';

  static bool get rememberMe => _box.read(_rememberMeKey) == true;

  static String? get rememberedLoginId {
    final value = _box.read(_rememberedLoginIdKey);
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static Future<void> setRememberMe(bool value) async {
    await _box.write(_rememberMeKey, value);
  }

  static Future<void> setRememberedLoginId(String loginId) async {
    await _box.write(_rememberedLoginIdKey, loginId.trim());
  }

  static Future<void> clearRememberedLoginId() async {
    await _box.remove(_rememberedLoginIdKey);
  }

  /// Profile fields used across the app (same keys as legacy [AuthController]).
  static Future<void> saveUserProfile(User user) async {
    await _box.write('token', user.accessToken);
    await _box.write('refresh_token', user.refreshToken);
    await _box.write('roles', user.roles.toString());
    await _box.write(
      'name',
      '${user.firstName} ${user.lastName} ${user.otherName}'.trim(),
    );
    await _box.write('phone_number', user.phoneNumber);
    await _box.write('email', user.email);
    await _box.write('is_verified', user.isVerified);
    await _box.write('id', user.id);
    if (user.roles.isNotEmpty) {
      await _box.write('role', user.roles.first.toString());
    }
  }

  static Future<void> clearProfile() async {
    for (final key in [
      'token',
      'refresh_token',
      'roles',
      'name',
      'phone_number',
      'email',
      'is_verified',
      'id',
      'role',
    ]) {
      await _box.remove(key);
    }
  }

  static Future<void> clearRememberMeSettings() async {
    await setRememberMe(false);
    await clearRememberedLoginId();
  }
}
