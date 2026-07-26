import 'package:get/get.dart';
import 'package:tisini/features/match_capture/domain/usecases/get_submitted_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/save_submitted_events.dart';
import 'package:tisini/features/match_capture/presentation/controllers/audit_events_controller.dart';

class AuditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatchEventsUsecase(repository: Get.find()));
    Get.lazyPut(() => UpdateMatchEventUsecase(repository: Get.find()));
    Get.lazyPut(() => DeleteMatchEventUsecase(repository: Get.find()));

    Get.lazyPut(() => GetSubmittedEventsUsecase(repository: Get.find()));
    Get.lazyPut(() => SaveSubmittedEventsUsecase(repository: Get.find()));

    Get.lazyPut(
      () => AuditEventsController(
        matchEvents: Get.find(),
        updateMatchEvent: Get.find(),
        deleteMatchEvent: Get.find(),
        getSubmittedEvents: Get.find(),
        saveSubmittedEvents: Get.find(),
      ),
    );
  }
}
