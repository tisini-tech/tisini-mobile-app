import 'package:get/get.dart';
import 'package:tisini/features/fixtures/data/datasources/fixture_remote_source.dart';
import 'package:tisini/features/fixtures/data/repositories/fixture_repository_impl.dart';
import 'package:tisini/features/fixtures/domain/repositories/fixture_repository.dart';
import 'package:tisini/features/fixtures/domain/usecases/fixtures.dart';
import 'package:tisini/features/fixtures/domain/usecases/fixture_dates.dart';
import 'package:tisini/features/fixtures/presentation/controllers/live_fixture_controller.dart';

class LiveFixturesBinding extends Bindings {
  @override
  void dependencies() {
    // Fixtures data layer
    Get.lazyPut<FixtureRemoteSource>(() => FixtureRemoteSourceImpl());
    Get.lazyPut<FixtureRepository>(
      () => FixtureRepositoryImpl(remoteSource: Get.find()),
    );

    // Domain layer (use case)
    Get.lazyPut(() => GetFixturesUsecase(fixtureRepository: Get.find()));
    Get.lazyPut(() => GetFixtureDatesUsecase(fixtureRepository: Get.find()));

    // Presentation layer (controller) — depends only on use case
    Get.lazyPut(
      () => LiveFixtureController(
        getFixtureDatesUsecase: Get.find(),
        getFixturesUsecase: Get.find(),
      ),
    );
  }
}
