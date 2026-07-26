import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/blog/data/datasources/blogs_remote_source.dart';
import 'package:tisini/features/blog/domain/repositories/blog_repository.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogsRemoteSource remoteSource;

  BlogRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, String>> getCategoryBlogs() async {
    try {
      final blogs = await remoteSource.getCategoryBlogs();

      return Right(blogs);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
