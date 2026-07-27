import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();

  Future<Either<Failure, void>> logout();
}
