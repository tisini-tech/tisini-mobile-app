import 'package:dio/dio.dart';
import 'package:tisini/core/constants/api_constants.dart';
import 'package:tisini/core/error/exceptions.dart';

/// HTTP client for ApiConstants.apiDataURL.
/// Uses `x-api-key` header (not Bearer Authorization).
class DataHttpService {
  static final DataHttpService _singleton = DataHttpService._internal();

  final Dio _dio = Dio();

  factory DataHttpService() => _singleton;

  DataHttpService._internal() {
    setUp();
  }

  /// Configures base URL and x-token header for apiDataURL calls.
  /// Uses [ApiConstants.xToken] by default, but allows override.
  Future<void> setUp({String? xToken}) async {
    final token = (xToken ?? ApiConstants.xToken).trim();
    final headers = <String, dynamic>{'Content-Type': 'application/json'};
    if (token.isNotEmpty) {
      headers['x-api-key'] = token;
    }

    _dio.options = BaseOptions(
      baseUrl: ApiConstants.apiDataURL,
      headers: headers,
      validateStatus: (status) {
        if (status == null) return false;
        return status < 500;
      },
    );
  }

  /// Update x-token without rebuilding all options.
  void setToken(String xToken) {
    if (xToken.isEmpty) return;
    final headers = Map<String, dynamic>.from(_dio.options.headers);
    headers['x-api-key'] = xToken;
    _dio.options = _dio.options.copyWith(headers: headers);
  }

  void clearToken() {
    final headers = Map<String, dynamic>.from(_dio.options.headers);
    headers.remove('x-api-key');
    _dio.options = _dio.options.copyWith(headers: headers);
  }

  Future<Response> post(String path, Map<String, dynamic> data) =>
      _request(() => _dio.post(path, data: data));

  Future<Response> get(String path) => _request(() => _dio.get(path));

  Future<Response> patch(String path, Map<String, dynamic> data) =>
      _request(() => _dio.patch(path, data: data));

  Future<Response> _request(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ServerException(message: _dioMessage(e));
    }
  }

  static String _dioMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Check your connection.';
      case DioExceptionType.connectionError:
        return 'No connection to server. Check your network.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode ?? 'unknown'}).';
      default:
        return e.message ?? 'Network request failed.';
    }
  }
}
