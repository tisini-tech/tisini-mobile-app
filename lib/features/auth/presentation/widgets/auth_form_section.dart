import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

/// Groups related auth inputs under a titled section.
class AuthFormSection extends StatelessWidget {
  const AuthFormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: TColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: TColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
