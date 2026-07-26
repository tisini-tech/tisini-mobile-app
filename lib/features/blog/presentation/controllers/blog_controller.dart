import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/blog/domain/usecases/blogs_category.dart';

class BlogController extends GetxController {
  final GetBlogsCategoryUsecase getBlogsCategoryUsecase;

  BlogController({required this.getBlogsCategoryUsecase});

  final Rx<String> blogsCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('BlogController.onInit called');
    getBlogsCategory();
  }

  void getBlogsCategory() async {
    debugPrint('BlogController.getBlogsCategory started');
    final result = await getBlogsCategoryUsecase.call(NoParams());
    debugPrint('BlogController.getBlogsCategory result received');

    result.fold(
      (failure) {
        showSnackbar('Error', failure.message, TColors.error);
      },
      (success) {
        print(success);
        blogsCategory.value = success;
      },
    );
  }
}
