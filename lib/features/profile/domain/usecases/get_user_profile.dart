import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/profile/domain/entities/user_profile.dart';
import 'package:tisini/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfileUsecase implements UseCase<UserProfile, NoParams> {
  GetUserProfileUsecase({required this.repository});

  final ProfileRepository repository;

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) {
    return repository.getUserProfile();
  }
}
