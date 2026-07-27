import 'package:get/get.dart';
import 'package:tisini/core/auth/session_service.dart';
import 'package:tisini/features/profile/data/datasources/profile_local_source.dart';
import 'package:tisini/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:tisini/features/profile/domain/repositories/profile_repository.dart';
import 'package:tisini/features/profile/domain/usecases/get_user_profile.dart';
import 'package:tisini/features/profile/domain/usecases/logout_user.dart';
import 'package:tisini/features/profile/presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileLocalSource>(
      () => ProfileLocalSourceImpl(sessionService: Get.find<SessionService>()),
    );
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(localSource: Get.find()),
    );

    Get.lazyPut(() => GetUserProfileUsecase(repository: Get.find()));
    Get.lazyPut(() => LogoutUserUsecase(repository: Get.find()));

    Get.lazyPut(
      () => ProfileController(
        getUserProfileUsecase: Get.find(),
        logoutUserUsecase: Get.find(),
      ),
    );
  }
}
