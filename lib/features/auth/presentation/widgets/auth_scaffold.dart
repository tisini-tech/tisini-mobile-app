import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

/// Reusable scaffold for auth screens (login, forgot password, verify, etc.).
/// Uses a clean gradient background and optional logo — no busy bg image.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.showLogo = true,
    this.logoPath = 'assets/tisini-logo.png',
    this.logoHeight = 80,
    this.implyLeading,
  });

  final Widget child;
  final bool showLogo;
  final String logoPath;
  final double logoHeight;

  /// When null, back is shown only if [Navigator.canPop].
  final bool? implyLeading;

  @override
  Widget build(BuildContext context) {
    final showBack = implyLeading ?? Navigator.canPop(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: TColors.textWhite,
        automaticallyImplyLeading: showBack,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [TColors.primary, Color(0xFF1565C0), TColors.accent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (showLogo) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Image.asset(
                    logoPath,
                    height: logoHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 80),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
