import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';

abstract interface class BlogRepository {
  Future<Either<Failure, String>> getCategoryBlogs();
}
