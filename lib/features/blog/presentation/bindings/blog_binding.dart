import 'package:get/get.dart';
import 'package:tisini/features/blog/data/datasources/blogs_remote_source.dart';
import 'package:tisini/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:tisini/features/blog/domain/repositories/blog_repository.dart';
import 'package:tisini/features/blog/domain/usecases/blogs_category.dart';
import 'package:tisini/features/blog/presentation/controllers/blog_controller.dart';

class BlogBinding extends Bindings {
  @override
  void dependencies() {
    // Data layer
    Get.lazyPut<BlogsRemoteSource>(() => BlogsRemoteSourceImpl());
    Get.lazyPut<BlogRepository>(
      () => BlogRepositoryImpl(remoteSource: Get.find()),
    );

    // Domain layer
    Get.lazyPut(() => GetBlogsCategoryUsecase(repository: Get.find()));

    // Presentation layer
    Get.lazyPut(() => BlogController(getBlogsCategoryUsecase: Get.find()));
  }
}
