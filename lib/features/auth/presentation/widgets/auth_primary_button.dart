import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

/// Primary CTA for auth screens. Stays branded while loading (no grey disabled state).
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.loadingLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final String loadingLabel;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          foregroundColor: TColors.white,
          disabledBackgroundColor: TColors.primary,
          disabledForegroundColor: TColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? () {} : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? Row(
                  key: const ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: TColors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loadingLabel,
                      style: _labelStyle,
                    ),
                  ],
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  style: _labelStyle,
                ),
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: TColors.white,
  );
}
