import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/features/survey/data/models/survey_model.dart';
import 'package:tisini/features/survey/data/models/upload_survey_result.dart';
import 'package:tisini/core/services/private_http_service.dart';

abstract interface class SurveyRemoteSource {
  Future<UploadSurveyResult> uploadPendingSurveys(
    List<Map<String, dynamic>> payloads,
  );

  Future<List<SurveyModel>> getSurvey();

  Future<String> saveSurvey(
    Map<String, dynamic> survey,
    String code,
    String surveyId,
    String localId,
    String savedAt,
  );
}

class SurveyRemoteSourceImpl implements SurveyRemoteSource {
  final PrivateHttpService _httpService;

  SurveyRemoteSourceImpl({PrivateHttpService? httpService})
    : _httpService = httpService ?? PrivateHttpService();

  @override
  Future<UploadSurveyResult> uploadPendingSurveys(
    List<Map<String, dynamic>> payloads,
  ) async {
    final response = await _httpService.post('', {
      'action': 'uploadsurveys',
      'payloads': payloads,
    });

    if (response == null) {
      throw ServerException(
        message: 'No response from server. Check connectivity.',
      );
    }

    // Get body: Dio uses response.data; some clients use .body or return body directly.
    final raw = _getResponseBody(response);
    Map<String, dynamic>? map;
    if (raw is Map) {
      map = Map<String, dynamic>.from(raw);
    } else if (raw is String) {
      try {
        map = jsonDecode(raw) as Map<String, dynamic>?;
      } catch (_) {
        map = null;
      }
    }

    if (map == null) {
      debugPrint('Survey upload raw response: $raw');
      throw ServerException(message: 'Empty or invalid response from server.');
    }

    final error = map['error']?.toString();
    if (error != null && error != '0') {
      throw ServerException(
        message: map['message']?.toString() ?? 'Upload failed.',
      );
    }

    final message = map['message']?.toString() ?? 'Synced';
    final surveyidsRaw = map['surveyids'];
    final surveyIds = <String>[];
    if (surveyidsRaw is List) {
      for (final e in surveyidsRaw) {
        if (e != null) surveyIds.add(e.toString());
      }
    }

    debugPrint('Survey upload response: $message, ids: $surveyIds');

    return UploadSurveyResult(message: message, surveyIds: surveyIds);
  }

  /// Supports Dio (response.data) or any object with .data/.body, or raw String/Map.
  dynamic _getResponseBody(dynamic response) {
    if (response == null) return null;
    try {
      if (response is Map || response is String) return response;
      final data = response.data;
      if (data != null) return data;
      final body = response.body;
      if (body != null) return body;
    } catch (_) {}
    return null;
  }

  @override
  Future<List<SurveyModel>> getSurvey() async {
    final response = await _httpService.post('', {
      'action': 'fetchengagementtitles',
    });
    debugPrint('Get survey response: $response');
    if (response == null) {
      throw ServerException(
        message: 'No response from server. Check connectivity.',
      );
    }

    final raw = response.data;
    final List<dynamic> resData = raw is String
        ? (json.decode(raw) as List<dynamic>)
        : raw is List
        ? List<dynamic>.from(raw)
        : <dynamic>[];

    return resData
        .map(
          (item) =>
              SurveyModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<String> saveSurvey(
    Map<String, dynamic> survey,
    String code,
    String surveyId,
    String localId,
    String savedAt,
  ) async {
    final response = await _httpService.post('', {
      "action": "saveengagementresponses",
      'engagement_id': surveyId,
      'referral': code,
      'survey': survey,
      'engagement_localtime': savedAt,
      'engagement_localid': localId,
    });
    debugPrint('Save survey response: $response');
    if (response == null) {
      throw ServerException(
        message: 'No response from server. Check connectivity.',
      );
    }

    final data = response.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'].toString();
    }

    if (data is List && data.isNotEmpty && data.first is Map) {
      final first = data.first as Map;
      if (first.containsKey('message')) return first['message'].toString();
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return 'Saved';
  }
}
