import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';
import 'package:tisini/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase implements UseCase<User, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUsecase({required this.repository});

  @override
  Future<Either<Failure, User>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      emailOrPhoneNumber: params.emailOrPhoneNumber,
      newPassword: params.newPassword,
      verificationCode: params.verificationCode,
    );
  }
}

class ResetPasswordParams {
  final String emailOrPhoneNumber;
  final String newPassword;
  final String verificationCode;

  ResetPasswordParams({
    required this.emailOrPhoneNumber,
    required this.newPassword,
    required this.verificationCode,
  });
}
