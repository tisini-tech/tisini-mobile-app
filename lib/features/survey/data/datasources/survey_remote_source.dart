import 'package:flutter/foundation.dart';
import 'package:tisini/core/services/http_response_body.dart';
import 'package:tisini/core/services/http_service.dart';
import 'package:tisini/features/survey/data/models/survey_model.dart';

abstract interface class SurveyRemoteSource {
  Future<List<SurveyModel>> getSurvey();

  Future<SurveyModel> getSurveyQuestions(String surveyId);

  Future<String> saveSurvey(List<Map<String, dynamic>> survey, String surveyId);
}

class SurveyRemoteSourceImpl implements SurveyRemoteSource {
  final HttpService _httpService;

  SurveyRemoteSourceImpl({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  @override
  Future<List<SurveyModel>> getSurvey() async {
    final response = await _httpService.get(
      '/engagements?type=SU',
      withApiKey: true,
    );

    HttpResponseBody.throwIfHttpError(response);
    final List<dynamic> resData = HttpResponseBody.requireList(response);

    return resData
        .map(
          (item) =>
              SurveyModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<SurveyModel> getSurveyQuestions(String surveyId) async {
    final response = await _httpService.get(
      '/engagements/$surveyId/questions',
      withApiKey: true,
    );
    debugPrint('Get survey questions: $response');
    HttpResponseBody.throwIfHttpError(response);
    final Map<String, dynamic> resData = HttpResponseBody.requireMap(response);

    return SurveyModel.fromJson(resData);
  }

  @override
  Future<String> saveSurvey(
    List<Map<String, dynamic>> survey,
    String surveyId,
  ) async {
    final response = await _httpService.post(
      '/engagements/$surveyId/answers',
      survey,
      withApiKey: true,
    );

    HttpResponseBody.throwIfHttpError(response);
    final Map<String, dynamic> resData = HttpResponseBody.requireMap(response);

    return resData['message'].toString();
  }
}
