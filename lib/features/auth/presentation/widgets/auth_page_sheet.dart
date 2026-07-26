import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

/// White rounded panel used on all auth flow screens.
class AuthPageSheet extends StatelessWidget {
  const AuthPageSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: const BoxDecoration(
              color: TColors.light,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(child: child),
          ),
        ),
      ],
    );
  }
}
