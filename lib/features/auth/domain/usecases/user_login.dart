import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/auth/domain/entities/user.dart';
import 'package:tisini/features/auth/domain/repositories/auth_repository.dart';

class UserLogin implements UseCase<User, UserLoginParams> {
  final AuthRepository repository;

  UserLogin({required this.repository});

  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    return await repository.loginWithEmailPassword(
      emailOrPhoneNumber: params.emailOrPhoneNumber,
      password: params.password,
    );
  }
}

class UserLoginParams {
  final String emailOrPhoneNumber;
  final String password;

  UserLoginParams({required this.emailOrPhoneNumber, required this.password});
}
