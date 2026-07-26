import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';

/// Used as [Params] when a use case has no parameters.
class NoParams {
  const NoParams();
}

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}
