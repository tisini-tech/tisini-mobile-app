import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/profile/domain/entities/user_profile.dart';
import 'package:tisini/features/profile/domain/usecases/get_user_profile.dart';
import 'package:tisini/features/profile/domain/usecases/logout_user.dart';

class ProfileController extends GetxController {
  ProfileController({
    required this.getUserProfileUsecase,
    required this.logoutUserUsecase,
  });

  final GetUserProfileUsecase getUserProfileUsecase;
  final LogoutUserUsecase logoutUserUsecase;

  final isLoading = false.obs;
  final isLoggingOut = false.obs;
  final profile = Rxn<UserProfile>();
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await getUserProfileUsecase(const NoParams());
    result.fold(
      (failure) {
        profile.value = null;
        errorMessage.value = failure.message;
      },
      (userProfile) {
        profile.value = userProfile;
        errorMessage.value = null;
      },
    );

    isLoading.value = false;
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await logout();
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: TColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    if (isLoggingOut.value) return;

    isLoggingOut.value = true;
    final result = await logoutUserUsecase(const NoParams());
    result.fold(
      (failure) {
        isLoggingOut.value = false;
        showSnackbar('Error', failure.message, Colors.red);
      },
      (_) {
        // Clear stack of protected routes after session is wiped.
        Get.offAllNamed('/login');
      },
    );
  }
}
