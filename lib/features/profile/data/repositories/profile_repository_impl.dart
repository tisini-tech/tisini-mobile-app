import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/profile/data/datasources/profile_local_source.dart';
import 'package:tisini/features/profile/domain/entities/user_profile.dart';
import 'package:tisini/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.localSource});

  final ProfileLocalSource localSource;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      return Right(localSource.getUserProfile());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
