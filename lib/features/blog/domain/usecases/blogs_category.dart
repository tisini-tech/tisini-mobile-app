import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/blog/domain/repositories/blog_repository.dart';

class GetBlogsCategoryUsecase implements UseCase<String, NoParams> {
  final BlogRepository repository;

  GetBlogsCategoryUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getCategoryBlogs();
  }
}

