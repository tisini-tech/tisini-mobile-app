import 'dart:convert';

import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/services/http_response_body.dart';
import 'package:tisini/core/services/http_service.dart';
import 'package:tisini/shared/fixture_data/data/models/match_data_model.dart';

abstract interface class FixtureDataRemoteSource {
  Future<Map<String, dynamic>> getFixtureData({required String fixtureId});

  Future<List<MatchDataModel>> getMatchData({required String fixtureId});
}

class FixtureDataRemoteSourceImpl implements FixtureDataRemoteSource {
  final HttpService _httpService;

  FixtureDataRemoteSourceImpl({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  @override
  Future<Map<String, dynamic>> getFixtureData({
    required String fixtureId,
  }) async {
    final response = await _httpService.get('event=$fixtureId');

    if (response == null) {
      throw ServerException(
        message: 'No response from server. Check connectivity.',
      );
    }

    final raw = response.data;
    if (raw == null) {
      throw ServerException(message: 'No fixture data in response.');
    }

    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String) {
      return Map<String, dynamic>.from(json.decode(raw) as Map);
    }
    throw ServerException(message: 'Unexpected fixture data format.');
  }

  @override
  Future<List<MatchDataModel>> getMatchData({required String fixtureId}) async {
    final response = await _httpService.get('/fixture-stats/$fixtureId');

    HttpResponseBody.throwIfHttpError(response);
    final items = HttpResponseBody.requireListOrResults(
      response,
      message: 'Invalid fixture stats response.',
    );

    return items.map(MatchDataModel.fromJson).toList();
  }
}
