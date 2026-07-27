import 'package:tisini/core/auth/session_service.dart';
import 'package:tisini/core/auth/user_session_prefs.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileLocalSource {
  UserProfile getUserProfile();

  Future<void> logout();
}

class ProfileLocalSourceImpl implements ProfileLocalSource {
  ProfileLocalSourceImpl({required this.sessionService});

  final SessionService sessionService;

  @override
  UserProfile getUserProfile() {
    final id = UserSessionPrefs.userId;
    final name = UserSessionPrefs.name;
    final email = UserSessionPrefs.email;

    if ((id == null || id.isEmpty) &&
        (name == null || name.isEmpty) &&
        (email == null || email.isEmpty)) {
      throw ServerException(message: 'No profile found. Please sign in again.');
    }

    return UserProfile(
      id: id ?? '',
      name: name ?? 'User',
      email: email ?? '',
      phoneNumber: UserSessionPrefs.phoneNumber ?? '',
      role: UserSessionPrefs.role ?? '',
      isVerified: UserSessionPrefs.isVerified,
    );
  }

  @override
  Future<void> logout() {
    return sessionService.clearSession(clearRememberMe: true);
  }
}
