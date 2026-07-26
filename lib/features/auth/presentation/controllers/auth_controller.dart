import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/auth/session_service.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';
import 'package:tisini/features/auth/domain/usecases/confirm_account.dart';
import 'package:tisini/features/auth/domain/usecases/reset_password.dart';
import 'package:tisini/features/auth/domain/usecases/verify_account.dart';
import 'package:tisini/features/auth/domain/usecases/user_login.dart';

/// Presentation layer: only talks to **use cases**, never to repositories or data sources.
/// Flow: User taps Sign In → [signIn] → [UserLogin] use case → API.
///
/// Session persistence is delegated to [SessionService].
/// See `lib/core/auth/SESSION_ARCHITECTURE.md`.
class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final UserLogin userLogin;
  final ConfirmAccountUsecase confirmAccountUsecase;
  final VerifyAccountUsecase verifyAccountUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;
  final SessionService sessionService;

  AuthController({
    required this.userLogin,
    required this.confirmAccountUsecase,
    required this.verifyAccountUsecase,
    required this.resetPasswordUsecase,
    required this.sessionService,
  });

  final TextEditingController emailOrPhoneNumber = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController verificationCode = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  GlobalKey<FormState> formSignInKey = GlobalKey<FormState>();
  final formResetPasswordKey = GlobalKey<FormState>();
  final formConfirmAccountKey = GlobalKey<FormState>();
  final formVerifyAccountKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final rememberPassword = false.obs;
  final RxString purpose = 'account_verify'.obs;

  /// Called when [LoginScreen] mounts so fields stay in sync after navigation.
  void prepareLoginForm({String? email}) {
    password.clear();
    verificationCode.clear();
    newPassword.clear();
    confirmPassword.clear();
    purpose.value = 'account_verify';
    formSignInKey = GlobalKey<FormState>();

    sessionService.applyRememberMeToForm(
      setRememberMe: (value) => rememberPassword.value = value,
      setLoginId: (loginId) => emailOrPhoneNumber.text = loginId,
    );

    if (email != null && email.isNotEmpty) {
      emailOrPhoneNumber.text = email;
    }
  }

  /// Silent sign-in using a stored refresh token (Remember me).
  Future<bool> tryRestoreSession() async {
    final result = await sessionService.tryRestoreSession();
    return result == SessionRestoreResult.authenticated;
  }

  Future<void> _persistAuthenticatedUser(
    User user, {
    required bool rememberMe,
  }) async {
    await sessionService.persistLogin(
      user: user,
      loginId: emailOrPhoneNumber.text.trim(),
      rememberMe: rememberMe,
    );
  }

  void gotoResetPassword() {
    purpose.value = 'password_reset';
    Get.offNamed('/confirm-account');
  }

  void toggleRememberMe(bool? value) {
    if (isClosed) return;
    rememberPassword.value = value ?? false;
  }

  void _setLoading(bool value) {
    if (!isClosed) isLoading.value = value;
  }

  void _unfocusAndNavigate(VoidCallback action) {
    FocusManager.instance.primaryFocus?.unfocus();
    action();
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your password';
    }
    return null;
  }

  String? validateEmailOrPhoneNumber(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Enter your email or phone number';
    }
    if (_isEmail(text)) {
      if (!_isValidEmail(text)) return 'Enter a valid email';
      return null;
    }
    if (!_isValidPhone(text)) return 'Enter a valid phone number';
    return null;
  }

  bool _isEmail(String value) => value.contains('@');

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 9 && digits.length <= 15;
  }

  String? validateVerificationCode(String? value) {
    final code = (value ?? verificationCode.text).trim();
    if (code.length != 6) {
      return 'Enter the 6-digit verification code';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'Code must contain only numbers';
    }
    return null;
  }

  /// At least 8 chars with upper, lower, digit, and any non-alphanumeric (e.g. # ! @).
  static final _passwordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  String? validateNewPassword(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Enter your new password';
    if (text.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_passwordPattern.hasMatch(text)) {
      return 'Include upper, lower, number, and a special character';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Confirm your new password';

    if (text != newPassword.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> signIn() async {
    if (!formSignInKey.currentState!.validate()) return;

    try {
      _setLoading(true);

      final result = await userLogin(
        UserLoginParams(
          emailOrPhoneNumber: emailOrPhoneNumber.text.trim(),
          password: password.text.trim(),
        ),
      );

      await result.fold(
        (failure) async {
          showSnackbar('Login failed', failure.message, Colors.red);
        },
        (user) async {
          if (!user.isVerified) {
            showSnackbar(
              'Login failed',
              'Please verify your account to continue',
              Colors.red,
            );
            _unfocusAndNavigate(() => Get.toNamed('/confirm-account'));
            return;
          }

          await _persistAuthenticatedUser(
            user,
            rememberMe: rememberPassword.value,
          );
          password.clear();

          _unfocusAndNavigate(() => Get.offAllNamed('/dashboard'));
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> confirmAccount() async {
    if (!formConfirmAccountKey.currentState!.validate()) return;

    try {
      _setLoading(true);

      final result = await confirmAccountUsecase(
        ConfirmAccountParams(
          emailOrPhoneNumber: emailOrPhoneNumber.text.trim(),
          purpose: purpose.value,
        ),
      );

      result.fold(
        (failure) {
          showSnackbar('Confirm account failed', failure.message, Colors.red);
        },
        (user) {
          showSnackbar(
            'Confirm account successful',
            'Verification code sent to your email or phone number',
            Colors.green,
          );

          if (purpose.value == 'account_verify') {
            _unfocusAndNavigate(() => Get.toNamed('/verify-account'));
          } else {
            _unfocusAndNavigate(() => Get.toNamed('/reset-password'));
          }
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyAccount() async {
    if (!formVerifyAccountKey.currentState!.validate()) return;

    try {
      _setLoading(true);

      final result = await verifyAccountUsecase(
        VerifyAccountParams(
          emailOrPhoneNumber: emailOrPhoneNumber.text.trim(),
          verificationCode: verificationCode.text.trim(),
        ),
      );

      await result.fold(
        (failure) async {
          showSnackbar('Verify account failed', failure.message, Colors.red);
        },
        (user) async {
          showSnackbar(
            'Verify account successful',
            'Account verified successfully',
            Colors.green,
          );

          await _persistAuthenticatedUser(user, rememberMe: false);
          password.clear();

          _unfocusAndNavigate(() => Get.offAllNamed('/dashboard'));
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendVerificationCode() async {
    final id = emailOrPhoneNumber.text.trim();
    if (id.isEmpty) {
      showSnackbar(
        'Resend failed',
        'Go back and enter your email or phone number first.',
        Colors.red,
      );
      return;
    }

    try {
      _setLoading(true);
      final result = await confirmAccountUsecase(
        ConfirmAccountParams(emailOrPhoneNumber: id, purpose: purpose.value),
      );

      result.fold(
        (failure) => showSnackbar('Resend failed', failure.message, Colors.red),
        (_) => showSnackbar(
          'Code sent',
          'A new verification code was sent.',
          Colors.green,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword() async {
    if (!formResetPasswordKey.currentState!.validate()) return;

    try {
      _setLoading(true);

      final result = await resetPasswordUsecase(
        ResetPasswordParams(
          emailOrPhoneNumber: emailOrPhoneNumber.text.trim(),
          newPassword: newPassword.text.trim(),
          verificationCode: verificationCode.text.trim(),
        ),
      );

      await result.fold(
        (failure) async {
          showSnackbar('Reset password failed', failure.message, Colors.red);
        },
        (_) async {
          showSnackbar(
            'Reset password successful',
            'Password reset successfully',
            Colors.green,
          );
          final email = emailOrPhoneNumber.text.trim();
          await sessionService.clearSession(clearRememberMe: false);
          _unfocusAndNavigate(
            () => Get.offAllNamed(
              '/login',
              arguments: {'email': email, 'skipRestore': true},
            ),
          );
        },
      );
    } finally {
      _setLoading(false);
    }
  }

}
