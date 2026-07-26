import 'package:get/get.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_local_source.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_remote_source.dart';
import 'package:tisini/features/match_capture/data/repositories/match_capture_repository_impl.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';
import 'package:tisini/features/match_capture/domain/usecases/team_lineup.dart';
import 'package:tisini/features/match_capture/domain/usecases/team_players.dart';
import 'package:tisini/features/match_capture/domain/usecases/add_player.dart';
import 'package:tisini/features/match_capture/domain/usecases/save_lineup.dart';
import 'package:tisini/features/match_capture/presentation/controllers/lineup_controller.dart';

class LineupBinding extends Bindings {
  @override
  void dependencies() {
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
    Get.lazyPut(() => TeamPlayersUsecase(repository: Get.find()));
    Get.lazyPut(() => TeamLineupUsecase(repository: Get.find()));
    Get.lazyPut(() => SaveLineupUsecase(repository: Get.find()));
    Get.lazyPut(() => AddPlayerUsecase(repository: Get.find()));
    Get.lazyPut(() => UpdateTeamPlayerUsecase(repository: Get.find()));

    // Presentation layer (controller) — depends only on use case
    Get.lazyPut(
      () => LineupController(
        teamPlayersUsecase: Get.find(),
        teamLineupUsecase: Get.find(),
        saveLineupUsecase: Get.find(),
        addPlayerUsecase: Get.find(),
        updateTeamPlayerUsecase: Get.find(),
      ),
    );
  }
}
