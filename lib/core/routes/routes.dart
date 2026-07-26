import 'package:get/get.dart';
import 'package:tisini/core/navigation/bindings/navigation_binding.dart';
import 'package:tisini/core/navigation/main_navigation.dart';
import 'package:tisini/core/navigation/public_navigation.dart';
import 'package:tisini/core/navigation/splash_screen.dart';
import 'package:tisini/features/auth/presentation/bindings/auth_binding.dart';
import 'package:tisini/features/auth/presentation/screens/login_screen.dart';
import 'package:tisini/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:tisini/features/auth/presentation/screens/confirm_screen.dart';
import 'package:tisini/features/auth/presentation/screens/verify_screen.dart';
import 'package:tisini/features/blog/presentation/bindings/blog_binding.dart';
import 'package:tisini/features/blog/presentation/pages/blog_screen.dart';
import 'package:tisini/features/fixtures/presentation/bindings/agent_fixture_binding.dart';
import 'package:tisini/features/fixtures/presentation/controllers/agent_fixture_controller.dart';
import 'package:tisini/features/fixtures/presentation/bindings/live_fixtures_binding.dart';
import 'package:tisini/features/fixtures/presentation/controllers/league_fixture_controller.dart';
import 'package:tisini/features/fixtures/presentation/pages/fixture_details_screen.dart';
import 'package:tisini/features/fixtures/presentation/bindings/fixture_details_binding.dart';
import 'package:tisini/features/match_capture/presentation/bindings/audit_binding.dart';
import 'package:tisini/features/match_capture/presentation/bindings/feedback_binding.dart';
import 'package:tisini/features/match_capture/presentation/bindings/lineup_binding.dart';
import 'package:tisini/features/match_capture/presentation/bindings/officials_binding.dart';
import 'package:tisini/features/fixtures/presentation/pages/agent_fixtures_screen.dart';
import 'package:tisini/features/fixtures/presentation/pages/fixture_options_screen.dart';
import 'package:tisini/features/match_capture/presentation/pages/audit_events_screen.dart';
import 'package:tisini/features/match_capture/presentation/pages/feedback_screen.dart';
import 'package:tisini/features/match_capture/presentation/pages/officials_screen.dart';
import 'package:tisini/features/match_capture/presentation/pages/select_lineups_screen.dart';
import 'package:tisini/features/match_capture/presentation/bindings/match_capture_binding.dart';
import 'package:tisini/features/match_capture/presentation/pages/match_capture_screen.dart';
import 'package:tisini/features/survey/presentation/bindings/engagement_binding.dart';
import 'package:tisini/features/survey/presentation/pages/engagement_screen.dart';

class AppPages {
  static final route = [
    // Splash screen
    GetPage(name: "/splash", page: () => const SplashScreen()),

    // Auth routes
    GetPage(
      name: "/login",
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: "/reset-password",
      page: () => const ResetPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: "/verify-account",
      page: () => const VerifyScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: "/confirm-account",
      page: () => const ConfirmScreen(),
      binding: AuthBinding(),
    ),
    // GetPage(
    //   name: "/register",
    //   page: () => SignupScreen(),
    //   binding: AuthBinding(),
    // ),

    // Public navigation (public routes)
    GetPage(
      name: "/home",
      page: () => const PublicNavigation(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PublicNavigationController());
        // FixtureBinding().dependencies();
        LiveFixturesBinding().dependencies();
        Get.lazyPut(() => LeagueFixtureController());
        BlogBinding().dependencies();
        EngagementBinding().dependencies();
      }),
    ),

    // Blog routes
    GetPage(
      name: "/blog",
      page: () => const BlogScreen(),
      binding: BlogBinding(),
    ),
    GetPage(
      name: "/survey",
      page: () => const EngagementScreen(),
      binding: EngagementBinding(),
    ),

    // Fixtures route - SEPARATE route (full screen, no bottom nav)
    GetPage(
      name: "/fixture-details",
      page: () => const FixtureDetailsScreen(),
      binding: FixtureDetailsBinding(),
    ),

    // Main navigation (protected routes)
    GetPage(
      name: "/dashboard",
      page: () => const MainNavigation(),
      binding: NavigationBinding(),
    ),
    GetPage(
      name: "/agent-fixtures",
      page: () => const AgentFixturesScreen(),
      binding: AgentFixtureBinding(),
    ),
    GetPage(
      name: "/audit-events",
      page: () => const AuditEventsScreen(),
      binding: AuditBinding(),
    ),
    GetPage(
      name: "/fixture-options",
      page: () => const FixtureOptionsScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AgentFixtureController>()) {
          AgentFixtureBinding().dependencies();
        }
        Get.find<AgentFixtureController>().applyRouteFixture(Get.arguments);
      }),
    ),
    GetPage(
      name: "/match-capture",
      page: () => const MatchCaptureScreen(),
      binding: MatchCaptureBinding(),
    ),
    GetPage(
      name: "/lineup-selector",
      page: () => SelectLineupsScreen(),
      binding: LineupBinding(),
    ),
    GetPage(
      name: "/feedback",
      page: () => const FeedbackScreen(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: "/match-officials",
      page: () => const MatchOfficialsScreen(),
      binding: MatchOfficialsBinding(),
    ),
    // Drawer routes (full screen)
    // GetPage(name: "/users", page: () => const UsersScreen()),
    // GetPage(name: "/inventory", page: () => const InventoryScreen()),
    // GetPage(name: "/settings", page: () => const SettingsScreen()),
  ];
}
