import 'package:get/get.dart';
import 'package:tisini/features/fixtures/data/datasources/agent_fixture_remote_source.dart';
import 'package:tisini/features/fixtures/data/repositories/agent_fixture_repository_impl.dart';
import 'package:tisini/features/fixtures/domain/repositories/agent_fixture_repository.dart';
import 'package:tisini/features/fixtures/domain/usecases/agent_fixtures.dart';
import 'package:tisini/features/fixtures/presentation/controllers/agent_fixture_controller.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_local_source.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_remote_source.dart';
import 'package:tisini/features/match_capture/data/repositories/match_capture_repository_impl.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';
import 'package:tisini/features/match_capture/domain/usecases/get_submitted_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/sync_events.dart';

class AgentFixtureBinding extends Bindings {
  @override
  void dependencies() {
    // Fixtures data layer
    Get.lazyPut<AgentFixtureRemoteSource>(() => AgentFixtureRemoteSourceImpl());
    Get.lazyPut<AgentFixtureRepository>(
      () => AgentFixtureRepositoryImpl(remoteSource: Get.find()),
    );
    // Match capture (for fixture events from local storage)
    Get.lazyPut<MatchCaptureLocalSource>(() => MatchCaptureLocalSourceImpl());
    Get.lazyPut<MatchCaptureRemoteSource>(() => MatchCaptureRemoteSourceImpl());
    Get.lazyPut<MatchCaptureRepository>(
      () => MatchCaptureRepositoryImpl(
        remoteSource: Get.find(),
        localSource: Get.find(),
      ),
    );
    Get.lazyPut(() => GetSubmittedEventsUsecase(repository: Get.find()));
    Get.lazyPut(() => SyncEventsUsecase(repository: Get.find()));
    // Domain layer (use case)
    Get.lazyPut(() => AgentFixtures(agentFixtureRepository: Get.find()));
    Get.lazyPut(
      () => DeactivateMatchUsecase(agentFixtureRepository: Get.find()),
    );
    // Presentation layer (controller)
    Get.lazyPut(
      () => AgentFixtureController(
        agentFixtures: Get.find(),
        getSubmittedEventsUsecase: Get.find(),
        syncEventsUsecase: Get.find(),
        deactivateMatchUsecase: Get.find(),
      ),
      fenix: true,
    );
  }
}
