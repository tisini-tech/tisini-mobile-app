import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';
import 'package:tisini/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String emailOrPhoneNumber,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.loginWithEmailPassword(
        emailOrPhoneNumber: emailOrPhoneNumber,
        password: password,
      );

      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> confirmAccount({
    required String emailOrPhoneNumber,
    required String purpose,
  }) async {
    try {
      final response = await remoteDataSource.confirmAccount(
        emailOrPhoneNumber: emailOrPhoneNumber,
        purpose: purpose,
      );

      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyAccount({
    required String emailOrPhoneNumber,
    required String verificationCode,
  }) async {
    try {
      final response = await remoteDataSource.verifyAccount(
        emailOrPhoneNumber: emailOrPhoneNumber,
        verificationCode: verificationCode,
      );

      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> resetPassword({
    required String emailOrPhoneNumber,
    required String newPassword,
    required String verificationCode,
  }) async {
    try {
      final response = await remoteDataSource.resetPassword(
        emailOrPhoneNumber: emailOrPhoneNumber,
        newPassword: newPassword,
        verificationCode: verificationCode,
      );

      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
