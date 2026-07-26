import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';
import 'package:tisini/features/auth/domain/repositories/auth_repository.dart';

class ConfirmAccountUsecase implements UseCase<User, ConfirmAccountParams> {
  final AuthRepository repository;

  ConfirmAccountUsecase({required this.repository});

  @override
  Future<Either<Failure, User>> call(ConfirmAccountParams params) async {
    return await repository.confirmAccount(
      emailOrPhoneNumber: params.emailOrPhoneNumber,
      purpose: params.purpose,
    );
  }
}

class ConfirmAccountParams {
  final String emailOrPhoneNumber;
  final String purpose;

  ConfirmAccountParams({
    required this.emailOrPhoneNumber,
    required this.purpose,
  });
}
