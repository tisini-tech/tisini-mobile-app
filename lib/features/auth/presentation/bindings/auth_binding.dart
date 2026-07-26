import 'package:get/get.dart';
import 'package:tisini/core/auth/session_service.dart';
import 'package:tisini/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tisini/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tisini/features/auth/domain/repositories/auth_repository.dart';
import 'package:tisini/features/auth/domain/usecases/confirm_account.dart';
import 'package:tisini/features/auth/domain/usecases/reset_password.dart';
import 'package:tisini/features/auth/domain/usecases/verify_account.dart';
import 'package:tisini/features/auth/domain/usecases/user_login.dart';
import 'package:tisini/features/auth/presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SessionService>()) {
      Get.put(SessionService(), permanent: true);
    }

    // Data layer
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: Get.find()),
    );

    // Domain layer (use case)
    Get.lazyPut(() => UserLogin(repository: Get.find()));
    Get.lazyPut(() => ConfirmAccountUsecase(repository: Get.find()));
    Get.lazyPut(() => VerifyAccountUsecase(repository: Get.find()));
    Get.lazyPut(() => ResetPasswordUsecase(repository: Get.find()));

    // One shared auth controller for the whole flow; must not be disposed
    // while auth screens still hold TextEditingControllers.
    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(
          userLogin: Get.find(),
          confirmAccountUsecase: Get.find(),
          verifyAccountUsecase: Get.find(),
          resetPasswordUsecase: Get.find(),
          sessionService: Get.find<SessionService>(),
        ),
        permanent: true,
      );
    }
  }
}
