import 'package:dio/dio.dart';
import 'package:tisini/core/auth/token_refresh_service.dart';
import 'package:tisini/core/constants/api_constants.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/services/auth_token_storage.dart';

class HttpService {
  static final HttpService _singleton = HttpService._internal();

  final Dio _dio = Dio();

  factory HttpService() => _singleton;

  HttpService._internal() {
    _dio.interceptors.add(_AuthInterceptor(_dio));
    setUp();
  }

  /// Sets Authorization on Dio. Uses [bearerToken] or the stored access token.
  Future<void> setUp({String? bearerToken}) async {
    final token = bearerToken ?? AuthTokenStorage.accessToken;
    final headers = <String, dynamic>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    _dio.options = BaseOptions(
      baseUrl: ApiConstants.apiURL,
      headers: headers,
      validateStatus: (status) {
        if (status == null) return false;
        return status < 500;
      },
    );
  }

  Future<Response> post(String path, dynamic data) =>
      _request(() => _dio.post(path, data: data));

  Future<Response> get(String path) => _request(() => _dio.get(path));

  Future<Response> patch(String path, dynamic data) =>
      _request(() => _dio.patch(path, data: data));

  Future<Response> delete(String path) => _request(() => _dio.delete(path));

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

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._dio);

  final Dio _dio;
  Future<bool>? _refreshInFlight;

  static bool _isRefreshPath(String path) =>
      path.contains('/auth/refresh-token');

  static bool _isPublicAuthPath(String path) {
    final p = path.toLowerCase();
    return p.contains('/auth/login') ||
        p.contains('/auth/register') ||
        p.contains('/auth/reset-password') ||
        p.contains('/auth/confirm-account') ||
        p.contains('/auth/verify-account');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isRefreshPath(options.path)) {
      final token = AuthTokenStorage.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.statusCode == 401 &&
        !_isRefreshPath(response.requestOptions.path) &&
        !_isPublicAuthPath(response.requestOptions.path)) {
      final retried = await _retryAfterRefresh(response.requestOptions);
      if (retried != null) {
        return handler.resolve(retried);
      }
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    if (status == 401 && !_isRefreshPath(path) && !_isPublicAuthPath(path)) {
      final retried = await _retryAfterRefresh(err.requestOptions);
      if (retried != null) {
        return handler.resolve(retried);
      }
    }
    handler.next(err);
  }

  Future<Response?> _retryAfterRefresh(RequestOptions failedRequest) async {
    final refreshed = await _refreshTokens();
    if (!refreshed) return null;

    final token = AuthTokenStorage.accessToken;
    if (token == null || token.isEmpty) return null;

    final options = failedRequest.copyWith(
      headers: {...failedRequest.headers, 'Authorization': 'Bearer $token'},
    );
    return _dio.fetch(options);
  }

  Future<bool> _refreshTokens() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    _refreshInFlight = _performRefresh();
    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _performRefresh() async {
    final refreshed = await TokenRefreshService.refresh();
    if (!refreshed) {
      await _onSessionExpired();
      return false;
    }

    final token = AuthTokenStorage.accessToken;
    if (token == null || token.isEmpty) {
      await _onSessionExpired();
      return false;
    }

    final headers = Map<String, dynamic>.from(_dio.options.headers);
    headers['Authorization'] = 'Bearer $token';
    _dio.options = _dio.options.copyWith(headers: headers);

    return true;
  }

  Future<void> _onSessionExpired() async {
    await AuthTokenStorage.clear();
    AuthTokenStorage.redirectToLogin();
  }
}
