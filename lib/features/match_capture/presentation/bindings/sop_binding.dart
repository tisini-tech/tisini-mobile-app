import 'package:get/get.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_local_source.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_remote_source.dart';
import 'package:tisini/features/match_capture/data/repositories/match_capture_repository_impl.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_sop.dart';
import 'package:tisini/features/match_capture/presentation/controllers/sop_controller.dart';

class SopBinding extends Bindings {
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

    // Domain layer (use cases)
    Get.lazyPut(() => MatchSopUsecase(repository: Get.find()));
    Get.lazyPut(() => UploadImageUsecase(repository: Get.find()));
    Get.lazyPut(() => CreateSopUsecase(repository: Get.find()));
    Get.lazyPut(() => UpdateSopUsecase(repository: Get.find()));

    // Presentation layer (controller) — depends only on use cases
    Get.lazyPut(
      () => SopController(
        getSopUsecase: Get.find(),
        uploadImageUsecase: Get.find(),
        createSopUsecase: Get.find(),
        updateSopUsecase: Get.find(),
      ),
    );
  }
}
