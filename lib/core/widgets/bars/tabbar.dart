import 'package:tisini/core/constants/colors.dart';
import 'package:flutter/material.dart';

class TTabbar extends StatelessWidget implements PreferredSizeWidget {
  const TTabbar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TColors.primaryBackground,
      child: TabBar(
        tabs: tabs,
        isScrollable: false,
        indicatorColor: TColors.primary,
        labelColor: TColors.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        unselectedLabelColor: TColors.darkGrey,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
