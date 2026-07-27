import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/profile/domain/repositories/profile_repository.dart';

class LogoutUserUsecase implements UseCase<void, NoParams> {
  LogoutUserUsecase({required this.repository});

  final ProfileRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
