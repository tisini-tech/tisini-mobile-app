import 'package:get/get.dart';
import 'package:tisini/features/fixtures/presentation/controllers/fixture_details_controller.dart';
import 'package:tisini/features/fixtures/data/datasources/fixture_remote_source.dart';
import 'package:tisini/features/fixtures/data/repositories/fixture_repository_impl.dart';
import 'package:tisini/features/fixtures/domain/repositories/fixture_repository.dart';
import 'package:tisini/features/fixtures/domain/usecases/fixture_details.dart';
import 'package:tisini/features/fixtures/domain/usecases/fixture_lineups.dart';

class FixtureDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FixtureRemoteSource>()) {
      Get.lazyPut<FixtureRemoteSource>(() => FixtureRemoteSourceImpl());
    }
    if (!Get.isRegistered<FixtureRepository>()) {
      Get.lazyPut<FixtureRepository>(
        () => FixtureRepositoryImpl(remoteSource: Get.find()),
      );
    }

    Get.lazyPut(() => GetFixtureDetailsUsecase(repository: Get.find()));
    Get.lazyPut(() => GetFixtureLineupsUsecase(repository: Get.find()));

    Get.lazyPut<FixtureDetailsController>(
      () => FixtureDetailsController(
        getFixtureDetailsUsecase: Get.find(),
        getFixtureLineupsUsecase: Get.find(),
      ),
      fenix: true,
    );
  }
}
