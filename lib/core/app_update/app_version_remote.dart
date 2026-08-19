import 'package:tisini/core/services/http_response_body.dart';
import 'package:tisini/core/services/http_service.dart';
import 'package:tisini/core/app_update/app_version.dart';

class AppVersionRemoteSource {
  AppVersionRemoteSource({HttpService? httpService})
    : _http = httpService ?? HttpService();

  final HttpService _http;

  Future<AppVersionConfig> fetch() async {
    final response = await _http.get('/app-version');
    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);
    return AppVersionConfig(
      android: _platform(data['android']),
      ios: _platform(data['ios']),
      message: data['message']?.toString() ??
          'Please update to continue capturing matches.',
    );
  }

  PlatformVersionPolicy _platform(dynamic raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    return PlatformVersionPolicy(
      minVersion: map['min_version']?.toString() ?? '0.0.0',
      latestVersion: map['latest_version']?.toString() ?? '0.0.0',
      force: map['force'] == true,
      storeUrl: map['store_url']?.toString() ?? '',
    );
  }
}
