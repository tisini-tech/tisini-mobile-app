import 'package:get/get.dart';
import 'package:tisini/features/fixtures/presentation/controllers/team_stats_controller.dart';
import 'package:tisini/shared/fixture_data/domain/repositories/fixture_data_repository.dart';
import 'package:tisini/shared/fixture_data/domain/usecases/match_data_usecase.dart';
import 'package:tisini/shared/fixture_data/fixture_data_binding.dart';

class TeamStatsBinding extends Bindings {
  @override
  void dependencies() {
    FixtureDataBinding().dependencies();
    Get.lazyPut(
      () => GetMatchDataUsecase(repository: Get.find<FixtureDataRepository>()),
    );
    Get.lazyPut(() => TeamStatsController(matchDataUsecase: Get.find()));
  }
}
