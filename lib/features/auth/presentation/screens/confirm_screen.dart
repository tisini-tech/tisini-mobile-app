import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/widgets/input_field.dart';
import 'package:tisini/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_form_section.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_page_header.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_page_sheet.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:tisini/features/auth/presentation/widgets/auth_scaffold.dart';

class ConfirmScreen extends GetView<AuthController> {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthPageSheet(
        child: Form(
          key: controller.formConfirmAccountKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthPageHeader(
                title: 'Confirm account',
                subtitle:
                    'We\'ll send a 6-digit code to verify your email or phone number.',
              ),
              const SizedBox(height: 28),
              AuthFormSection(
                title: 'Contact details',
                subtitle:
                    'Enter the email or phone number you used when registering.',
                children: [
                  InputField(
                    label: 'Email or phone number',
                    errorMsg: 'Enter your email or phone number',
                    hintText: 'you@example.com or +254712345678',
                    controller: controller.emailOrPhoneNumber,
                    validator: controller.validateEmailOrPhoneNumber,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Obx(
                () => AuthPrimaryButton(
                  label: 'Send verification code',
                  loadingLabel: 'Sending code...',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.confirmAccount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
