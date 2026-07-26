import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

class AuthResendLink extends StatelessWidget {
  const AuthResendLink({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: isLoading ? null : onTap,
        style: TextButton.styleFrom(
          foregroundColor: TColors.primary,
          disabledForegroundColor: TColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          isLoading ? 'Sending...' : 'Didn\'t get a code? Resend',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
