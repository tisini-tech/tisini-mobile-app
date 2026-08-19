import 'package:get/get.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_local_source.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_remote_source.dart';
import 'package:tisini/features/match_capture/data/repositories/match_capture_repository_impl.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';
import 'package:tisini/features/match_capture/domain/usecases/agent_arrival.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_sop.dart';
import 'package:tisini/features/match_capture/presentation/controllers/agent_arrival_controller.dart';

class AgentArrivalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchCaptureRemoteSource>(() => MatchCaptureRemoteSourceImpl());
    Get.lazyPut<MatchCaptureLocalSource>(() => MatchCaptureLocalSourceImpl());
    Get.lazyPut<MatchCaptureRepository>(
      () => MatchCaptureRepositoryImpl(
        remoteSource: Get.find(),
        localSource: Get.find(),
      ),
    );

    Get.lazyPut(() => UploadImageUsecase(repository: Get.find()));
    Get.lazyPut(() => GetAgentArrivalUsecase(repository: Get.find()));
    Get.lazyPut(() => CreateAgentArrivalUsecase(repository: Get.find()));

    Get.lazyPut(
      () => AgentArrivalController(
        getAgentArrivalUsecase: Get.find(),
        uploadImageUsecase: Get.find(),
        createAgentArrivalUsecase: Get.find(),
      ),
    );
  }
}
