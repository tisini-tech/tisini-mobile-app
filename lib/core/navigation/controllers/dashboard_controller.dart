import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tisini/features/fixtures/presentation/pages/agent_fixtures_screen.dart';
import 'package:tisini/features/events/presentation/pages/events_screen.dart';

/// Role-based dashboard: exposes screens and tabs per user role.
/// Uses domain [User] (not UserModel). Single source of truth per role.
class DashboardController extends GetxController {
  final _box = GetStorage();

  final Rx<String> userRole = ''.obs;
  final RxInt selectedIndex = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  /// Loads user from storage and sets [userRole]. Call this on init and after login.
  Future<void> _loadUser() async {
    try {
      isLoading.value = true;
      final role = _box.read('role');

      if (role is String) {
        userRole.value = role;
      }
    } catch (_) {
      userRole.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  /// Single source of truth: role -> list of (screen, tab).
  /// Add/remove items here; screens and tabs stay in sync.
  List<DashboardNavItem> _navItemsForRole(String role) {
    switch (role) {
      case '5': // player
        return const [
          DashboardNavItem(
            screen: _OverviewPlaceholder(),
            icon: Icons.home,
            label: 'Home',
          ),
          DashboardNavItem(
            screen: EventsScreen(),
            icon: Icons.wallet,
            label: 'Wallet',
          ),
          DashboardNavItem(
            screen: _ProfilePlaceholder(),
            icon: Icons.person,
            label: 'Profile',
          ),
        ];
      case '1': // agent
      case '7': // superagent
        return const [
          DashboardNavItem(
            screen: AgentFixturesScreen(),
            icon: Icons.analytics,
            label: 'Metrics',
          ),
          DashboardNavItem(
            screen: _OverviewPlaceholder(),
            icon: Icons.home,
            label: 'Home',
          ),
          DashboardNavItem(
            screen: EventsScreen(),
            icon: Icons.wallet,
            label: 'Wallet',
          ),
          DashboardNavItem(
            screen: _ProfilePlaceholder(),
            icon: Icons.person,
            label: 'Profile',
          ),
        ];
      default:
        return const [
          DashboardNavItem(
            screen: AgentFixturesScreen(),
            icon: Icons.analytics,
            label: 'Metrics',
          ),
          DashboardNavItem(
            screen: _OverviewPlaceholder(),
            icon: Icons.home,
            label: 'Home',
          ),
          DashboardNavItem(
            screen: _ProfilePlaceholder(),
            icon: Icons.person,
            label: 'Profile',
          ),
          DashboardNavItem(
            screen: EventsScreen(),
            icon: Icons.wallet,
            label: 'Wallet',
          ),
        ];
    }
  }

  List<Widget> get screens =>
      _navItemsForRole(userRole.value).map((e) => e.screen).toList();
  List<GButton> get tabs => _navItemsForRole(
    userRole.value,
  ).map((e) => GButton(icon: e.icon, text: e.label)).toList();
}

class DashboardNavItem {
  const DashboardNavItem({
    required this.screen,
    required this.icon,
    required this.label,
  });
  final Widget screen;
  final IconData icon;
  final String label;
}

// Placeholders — replace with real screens (OverviewScreen, MetricsScreen, etc.)
class _OverviewPlaceholder extends StatelessWidget {
  const _OverviewPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Overview')),
    body: const Center(child: Text('Overview')),
  );
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: const Center(child: Text('Profile')),
  );
}
