import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/input_field.dart';
import 'package:tisini/core/widgets/verification_code_field.dart';
import 'package:tisini/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_form_section.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_page_header.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_page_sheet.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_resend_link.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_scaffold.dart';

class ResetPasswordScreen extends GetView<AuthController> {
  const ResetPasswordScreen({super.key});

  String get _subtitle {
    final id = controller.emailOrPhoneNumber.text.trim();
    if (id.isEmpty) {
      return 'Enter the code we sent you, then choose a new password.';
    }
    return 'Code sent to $id. Enter it below and set a new password.';
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthPageSheet(
        child: Form(
          key: controller.formResetPasswordKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthPageHeader(
                title: 'Reset password',
                subtitle: _subtitle,
              ),
              const SizedBox(height: 28),
              AuthFormSection(
                title: '1. Verification code',
                subtitle: '6-digit code from your email or SMS',
                children: [
                  VerificationCodeField(
                    controller: controller.verificationCode,
                    validator: controller.validateVerificationCode,
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => AuthResendLink(
                      isLoading: controller.isLoading.value,
                      onTap: controller.resendVerificationCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 32, color: TColors.dark),
              const SizedBox(height: 8),
              AuthFormSection(
                title: '2. New password',
                subtitle:
                    'At least 8 characters with upper & lower case, a number, and a symbol.',
                children: [
                  InputField(
                    label: 'New password',
                    errorMsg: 'New password is required',
                    hintText: 'Create a strong password',
                    password: true,
                    controller: controller.newPassword,
                    validator: controller.validateNewPassword,
                  ),
                  const SizedBox(height: 20),
                  InputField(
                    label: 'Confirm password',
                    errorMsg: 'Please confirm your password',
                    hintText: 'Re-enter your password',
                    password: true,
                    controller: controller.confirmPassword,
                    validator: controller.validateConfirmPassword,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Obx(
                () => AuthPrimaryButton(
                  label: 'Reset password',
                  loadingLabel: 'Resetting password...',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.resetPassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
