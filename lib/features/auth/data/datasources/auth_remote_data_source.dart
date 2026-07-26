import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/services/http_response_body.dart';
import 'package:tisini/core/services/http_service.dart';
import 'package:tisini/features/auth/data/models/user_model.dart';

/// Contract for auth remote operations (e.g. login).
/// Data sources sit in the data layer and talk to external APIs.
abstract interface class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailPassword({
    required String emailOrPhoneNumber,
    required String password,
  });

  Future<UserModel> confirmAccount({
    required String emailOrPhoneNumber,
    required String purpose,
  });

  Future<UserModel> verifyAccount({
    required String emailOrPhoneNumber,
    required String verificationCode,
  });

  Future<UserModel> resetPassword({
    required String emailOrPhoneNumber,
    required String newPassword,
    required String verificationCode,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpService _httpService;

  AuthRemoteDataSourceImpl({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  @override
  Future<UserModel> loginWithEmailPassword({
    required String emailOrPhoneNumber,
    required String password,
  }) async {
    final body = <String, dynamic>{
      "email_or_phone_number": emailOrPhoneNumber,
      "password": password,
    };

    final response = await _httpService.post('/auth/login', body);

    HttpResponseBody.throwIfHttpError(response, fallback: 'Login failed');
    final data = HttpResponseBody.requireMap(response);

    if ((data['access_token']?.toString() ?? '').isEmpty) {
      throw ServerException(message: 'Invalid response: try again!');
    }

    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> confirmAccount({
    required String emailOrPhoneNumber,
    required String purpose,
  }) async {
    final body = <String, dynamic>{
      "email_or_phone_number": emailOrPhoneNumber,
      "purpose": purpose,
    };

    final response = await _httpService.post('/auth/request-otp', body);

    HttpResponseBody.throwIfHttpError(
      response,
      fallback: 'Confirm account failed',
    );
    final data = HttpResponseBody.requireMap(response);

    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> verifyAccount({
    required String emailOrPhoneNumber,
    required String verificationCode,
  }) async {
    final body = <String, dynamic>{
      "email_or_phone_number": emailOrPhoneNumber,
      "otp_code": verificationCode,
    };

    final response = await _httpService.post('/auth/verify-account', body);

    HttpResponseBody.throwIfHttpError(
      response,
      fallback: 'Verify account failed',
    );
    final data = HttpResponseBody.requireMap(response);

    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> resetPassword({
    required String emailOrPhoneNumber,
    required String newPassword,
    required String verificationCode,
  }) async {
    final body = <String, dynamic>{
      "email_or_phone_number": emailOrPhoneNumber,
      "password": newPassword,
      "otp_code": verificationCode,
    };

    final response = await _httpService.post('/auth/reset-password', body);

    HttpResponseBody.throwIfHttpError(
      response,
      fallback: 'Reset password failed',
    );
    final data = HttpResponseBody.requireMap(response);

    return UserModel.fromJson(data);
  }
}
