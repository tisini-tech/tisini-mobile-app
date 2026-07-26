import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String emailOrPhoneNumber,
    required String password,
  });

  Future<Either<Failure, User>> confirmAccount({
    required String emailOrPhoneNumber,
    required String purpose,
  });

  Future<Either<Failure, User>> verifyAccount({
    required String emailOrPhoneNumber,
    required String verificationCode,
  });

  Future<Either<Failure, User>> resetPassword({
    required String emailOrPhoneNumber,
    required String newPassword,
    required String verificationCode,
  });
}
