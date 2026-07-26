import 'package:get/get.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_local_source.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_remote_source.dart';
import 'package:tisini/features/match_capture/data/repositories/match_capture_repository_impl.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';
import 'package:tisini/features/match_capture/domain/usecases/event_category.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_metrics.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_scores.dart';
import 'package:tisini/features/match_capture/presentation/controllers/fixture_event_carousel_controller.dart';
import 'package:tisini/features/match_capture/domain/usecases/save_match_event_locally.dart';
import 'package:tisini/features/match_capture/domain/usecases/save_submitted_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/update_match_event_status.dart';
import 'package:tisini/features/match_capture/domain/usecases/start_end_match.dart';
import 'package:tisini/features/match_capture/domain/usecases/team_lineup.dart';
import 'package:tisini/features/match_capture/domain/usecases/swap_players.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/controllers/timer_controller.dart';
import 'package:tisini/shared/fixture_data/domain/repositories/fixture_data_repository.dart';
import 'package:tisini/shared/fixture_data/domain/usecases/match_data_usecase.dart';
import 'package:tisini/shared/fixture_data/fixture_data_binding.dart';

class MatchCaptureBinding extends Bindings {
  @override
  void dependencies() {
    FixtureDataBinding().dependencies();

    // Data layer
    Get.lazyPut<MatchCaptureRemoteSource>(() => MatchCaptureRemoteSourceImpl());
    Get.lazyPut<MatchCaptureLocalSource>(() => MatchCaptureLocalSourceImpl());
    Get.lazyPut<MatchCaptureRepository>(
      () => MatchCaptureRepositoryImpl(
        remoteSource: Get.find(),
        localSource: Get.find(),
      ),
    );

    // Domain layer (use case)
    Get.lazyPut(() => MatchMetricsUsecase(repository: Get.find()));
    Get.lazyPut(() => MatchEventsUsecase(repository: Get.find()));
    Get.lazyPut(() => SaveSubmittedEventsUsecase(repository: Get.find()));
    Get.lazyPut(() => SaveMatchEventLocally(repository: Get.find()));
    Get.lazyPut(() => UpdateMatchEventStatus(repository: Get.find()));
    Get.lazyPut(() => CreateMatchEventUsecase(repository: Get.find()));
    Get.lazyPut(() => StartMatchUsecase(repository: Get.find()));
    Get.lazyPut(() => EndHalfUsecase(repository: Get.find()));
    Get.lazyPut(() => TeamLineupUsecase(repository: Get.find()));
    Get.lazyPut(() => SwapPlayersUsecase(repository: Get.find()));
    Get.lazyPut(() => MatchScoresUsecase(repository: Get.find()));
    Get.lazyPut(
      () => GetMatchDataUsecase(repository: Get.find<FixtureDataRepository>()),
    );
    Get.lazyPut(() => GetMatchEventCategoriesUseCase(repository: Get.find()));
    // Timer depends on MatchCaptureController (fixture); register MC first.
    Get.lazyPut(
      () => MatchCaptureController(
        matchMetrics: Get.find(),
        createMatchEvent: Get.find(),
        getFixtureDataUsecase: Get.find(),
        teamLineup: Get.find(),
        saveMatchEventLocally: Get.find(),
        updateMatchEventStatus: Get.find(),
        swapPlayersUsecase: Get.find(),
        matchScoresUsecase: Get.find(),
        matchDataUsecase: Get.find(),
        getMatchEventCategories: Get.find(),
      ),
    );

    Get.lazyPut(
      () => TimerController(
        startMatchUsecase: Get.find(),
        endHalfUsecase: Get.find(),
      ),
    );

    Get.lazyPut(() => FixtureEventCarouselController());
  }
}
