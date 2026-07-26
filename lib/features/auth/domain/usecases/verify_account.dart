import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';
import 'package:tisini/features/auth/domain/repositories/auth_repository.dart';

class VerifyAccountUsecase implements UseCase<User, VerifyAccountParams> {
  final AuthRepository repository;

  VerifyAccountUsecase({required this.repository});

  @override
  Future<Either<Failure, User>> call(VerifyAccountParams params) async {
    return await repository.verifyAccount(
      emailOrPhoneNumber: params.emailOrPhoneNumber,
      verificationCode: params.verificationCode,
    );
  }
}

class VerifyAccountParams {
  final String emailOrPhoneNumber;
  final String verificationCode;

  VerifyAccountParams({
    required this.emailOrPhoneNumber,
    required this.verificationCode,
  });
}
