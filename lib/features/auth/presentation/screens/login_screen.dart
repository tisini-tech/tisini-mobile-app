import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/auth/session_service.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/input_field.dart';
import 'package:tisini/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_form_section.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_page_header.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_page_sheet.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthController controller;
  bool _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (!Get.isRegistered<SessionService>()) {
      Get.put(SessionService(), permanent: true);
    }

    final args = Get.arguments;
    final skipRestore = _readSkipRestore(args);
    final email = _readEmailArg(args);

    try {
      if (!skipRestore) {
        final restored = await controller.tryRestoreSession();
        if (!mounted) return;
        if (restored) {
          Get.offAllNamed('/dashboard');
          return;
        }
      }

      if (!mounted) return;
      controller.prepareLoginForm(email: email);
    } finally {
      if (mounted) {
        setState(() => _bootstrapping = false);
      }
    }
  }

  bool _readSkipRestore(Object? args) {
    if (args is Map) {
      return args['skipRestore'] == true;
    }
    return false;
  }

  String? _readEmailArg(Object? args) {
    if (args is String && args.isNotEmpty) return args;
    if (args is Map) {
      final email = args['email'];
      if (email is String && email.isNotEmpty) return email;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) {
      return const AuthScaffold(
        implyLeading: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AuthScaffold(
      child: AuthPageSheet(
        child: Form(
          key: controller.formSignInKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthPageHeader(
                title: 'Welcome back',
                subtitle:
                    'Sign in with your email or phone number and password.',
              ),
              const SizedBox(height: 28),
              AuthFormSection(
                title: 'Your account',
                subtitle:
                    'Use the email or phone number linked to your account.',
                children: [
                  InputField(
                    label: 'Email or phone number',
                    errorMsg: 'Email or phone number is required',
                    hintText: 'you@example.com or +254712345678',
                    controller: controller.emailOrPhoneNumber,
                    validator: controller.validateEmailOrPhoneNumber,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    label: 'Password',
                    errorMsg: 'Password is required',
                    hintText: 'Enter your password',
                    password: true,
                    controller: controller.password,
                    validator: controller.validatePassword,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _optionsRow(),
              const SizedBox(height: 28),
              Obx(
                () => AuthPrimaryButton(
                  label: 'Sign in',
                  loadingLabel: 'Signing in...',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.signIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Obx(
              () => Checkbox(
                value: controller.rememberPassword.value,
                onChanged: controller.toggleRememberMe,
                activeColor: TColors.primary,
                fillColor: WidgetStateProperty.resolveWith(
                  (_) => TColors.primary,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            GestureDetector(
              onTap: () => controller.toggleRememberMe(
                !controller.rememberPassword.value,
              ),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Text(
                  'Remember me',
                  style: TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: controller.gotoResetPassword,
          style: TextButton.styleFrom(
            foregroundColor: TColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'Forgot password?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
