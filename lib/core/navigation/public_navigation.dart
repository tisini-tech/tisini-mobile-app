import 'package:tisini/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tisini/core/navigation/more_screen.dart';
import 'package:tisini/features/blog/presentation/pages/blog_screen.dart';
import 'package:tisini/features/fixtures/presentation/pages/leagues_screen.dart';
import 'package:tisini/features/fixtures/presentation/pages/live_fixtures_screen.dart';

class PublicNavigation extends GetView<PublicNavigationController> {
  const PublicNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: TColors.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: GNav(
            onTabChange: (value) {
              controller.selectedIndex.value = value;
            },
            backgroundColor: TColors.primary,
            rippleColor: TColors.grey,
            hoverColor: TColors.grey,
            haptic: true,
            tabBorderRadius: 15,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 250),
            gap: 8,
            color: TColors.textPrimary,
            activeColor: TColors.textWhite,
            iconSize: 24,
            tabBackgroundColor: TColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            tabs: const [
              GButton(icon: Icons.live_tv, text: "Live"),
              GButton(icon: Icons.emoji_events_rounded, text: "Leagues"),
              GButton(icon: Icons.receipt_rounded, text: "Stories"),
              GButton(icon: Icons.more_vert, text: "More"),
            ],
          ),
        ),
      ),
      body: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Container(
            key: ValueKey<int>(controller.selectedIndex.value),
            child: controller.screens[controller.selectedIndex.value],
          ),
        );
      }),
    );
  }
}

class PublicNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  // Screens with fixtures integrated - preserves bottomNavigationBar
  // Each tab shows fixtures for that sport type
  List<Widget> get screens => [
    // Football tab - shows football fixtures
    // const FixturesScreen(key: ValueKey('football'), fixtureType: 'football'),
    const LiveFixturesScreen(key: ValueKey('live-fixtures')),
    const LeaguesScreen(key: ValueKey('leagues')),
    // Rugby tab - shows rugby fixtures
    // const FixturesScreen(key: ValueKey('rugby'), fixtureType: 'rugby'),
    // Stories tab
    const BlogScreen(key: ValueKey('stories')),
    const MoreScreen(key: ValueKey('more')),
    // Survey tab
    // const EngagementScreen(key: ValueKey('survey')),
  ];
}
