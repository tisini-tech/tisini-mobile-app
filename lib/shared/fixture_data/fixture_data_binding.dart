import 'package:get/get.dart';
import 'package:tisini/shared/fixture_data/data/datasources/fixture_data_remote_source.dart';
import 'package:tisini/shared/fixture_data/data/repositories/fixture_data_repository_impl.dart';
import 'package:tisini/shared/fixture_data/domain/repositories/fixture_data_repository.dart';
import 'package:tisini/shared/fixture_data/domain/usecases/get_fixture_data_usecase.dart';
import 'package:tisini/shared/fixture_data/domain/usecases/match_data_usecase.dart';

/// Register shared fixture-data dependencies. Call from fixtures or match_capture bindings.
class FixtureDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FixtureDataRemoteSource>(
      () => FixtureDataRemoteSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<FixtureDataRepository>(
      () => FixtureDataRepositoryImpl(remoteSource: Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetFixtureDataUsecase(repository: Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetMatchDataUsecase(repository: Get.find()),
      fenix: true,
    );
  }
}
