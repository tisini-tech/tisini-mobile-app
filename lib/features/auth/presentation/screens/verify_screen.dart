import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/widgets/verification_code_field.dart';
import 'package:tisini/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_form_section.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_page_header.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_page_sheet.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_resend_link.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_scaffold.dart';

class VerifyScreen extends GetView<AuthController> {
  const VerifyScreen({super.key});

  String get _subtitle {
    final id = controller.emailOrPhoneNumber.text.trim();
    if (id.isEmpty) {
      return 'Enter the 6-digit code we sent to your email or phone number.';
    }
    return 'Enter the code sent to $id.';
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthPageSheet(
        child: Form(
          key: controller.formVerifyAccountKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthPageHeader(
                title: 'Verify account',
                subtitle: _subtitle,
              ),
              const SizedBox(height: 28),
              AuthFormSection(
                title: 'Verification code',
                subtitle: '6-digit code from your email or SMS.',
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
              const SizedBox(height: 32),
              Obx(
                () => AuthPrimaryButton(
                  label: 'Verify account',
                  loadingLabel: 'Verifying...',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.verifyAccount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
