import 'package:flutter/material.dart';

/// Slightly taller than default so logo + sport select read clearly.
const double _kAppBarHeight = 64;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _kAppBarHeight,
      centerTitle: false,
      titleSpacing: 16,
      title: Image.asset(
        'assets/tisini-logo.png',
        height: 48,
        fit: BoxFit.contain,
      ),
      actions: [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_kAppBarHeight);
}
