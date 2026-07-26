import 'package:get/get.dart';
import 'package:tisini/core/navigation/controllers/dashboard_controller.dart';
import 'package:tisini/features/events/presentation/bindings/events_binding.dart';
import 'package:tisini/features/fixtures/presentation/bindings/agent_fixture_binding.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    AgentFixtureBinding().dependencies();
    EventsBinding().dependencies();
  }
}
