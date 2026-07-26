import 'package:tisini/core/constants/api_constants.dart';
import 'package:dio/dio.dart';

class TicketsHttpService {
  static final TicketsHttpService _singleton = TicketsHttpService._internal();

  final _dio = Dio();

  factory TicketsHttpService() {
    return _singleton;
  }

  TicketsHttpService._internal() {
    setUp();
  }

  Future<void> setUp({String? bearerToken}) async {
    final headers = {"Content-Type": "application/json"};

    // if (bearerToken != null) {
    //   headers["Authorization"] = "Bearer $bearerToken";
    // }

    final options = BaseOptions(
      baseUrl: ApiConstants.apieventsURL,
      headers: headers,
      validateStatus: (status) {
        if (status == null) return false;
        return status < 500;
      },
    );

    _dio.options = options;
  }

  Future<Response?> post(String path, Map data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Response?> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } catch (e) {
      print(e);
    }
    return null;
  }
}
