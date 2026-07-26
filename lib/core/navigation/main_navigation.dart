import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/navigation/controllers/dashboard_controller.dart';

/// Role-based dashboard: bottom nav screens and tabs depend on [DashboardController.userRole].
class MainNavigation extends GetView<DashboardController> {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final screens = controller.screens;
        final index = controller.selectedIndex.value;

        if (screens.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return screens[index.clamp(0, screens.length - 1)];
      }),
      bottomNavigationBar: Container(
        color: TColors.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Obx(() {
            final tabs = controller.tabs;
            if (tabs.isEmpty) return const SizedBox.shrink();
            return GNav(
              selectedIndex: controller.selectedIndex.value,
              onTabChange: (value) => controller.selectedIndex.value = value,
              backgroundColor: TColors.primary,
              rippleColor: TColors.grey,
              hoverColor: TColors.grey,
              haptic: true,
              tabBorderRadius: 15,
              curve: Curves.easeOutExpo,
              duration: const Duration(milliseconds: 300),
              gap: 8,
              color: TColors.textPrimary,
              activeColor: TColors.textWhite,
              iconSize: 24,
              tabBackgroundColor: TColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              tabs: tabs,
            );
          }),
        ),
      ),
    );
  }
}
