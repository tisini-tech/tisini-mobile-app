import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/services/http_response_body.dart';
import 'package:tisini/core/services/data_http_service.dart';
import 'package:tisini/features/fixtures/data/models/fixture_detail_model.dart';
import 'package:tisini/features/fixtures/data/models/fixture_lineup_model.dart';
import 'package:tisini/features/fixtures/data/models/fixture_model.dart';

abstract interface class FixtureRemoteSource {
  Future<List<FixtureModel>> getFixtures({
    required String matchDate,
    required String fixtureType,
  });

  Future<List<String>> getFixtureDates({required String fixtureType});

  Future<FixtureDetailModel> getFixtureDetails({required String fixtureId});

  Future<FixtureLineupModel> getFixtureLineups({required String fixtureId});
}

class FixtureRemoteSourceImpl implements FixtureRemoteSource {
  final DataHttpService _httpService;

  FixtureRemoteSourceImpl({DataHttpService? httpService})
    : _httpService = httpService ?? DataHttpService();

  @override
  Future<List<String>> getFixtureDates({required String fixtureType}) async {
    final response = await _httpService.get('/scores/match-dates/$fixtureType');
    HttpResponseBody.throwIfHttpError(response);

    final items = HttpResponseBody.asList(response.data);
    if (items == null) {
      throw ServerException(message: 'Invalid match dates response.');
    }

    return items.map((item) => item.toString()).toList();
  }

  @override
  Future<List<FixtureModel>> getFixtures({
    required String matchDate,
    required String fixtureType,
  }) async {
    final response = await _httpService.get(
      '/scores/matches-by-date/$matchDate?fixture_type=$fixtureType',
    );

    HttpResponseBody.throwIfHttpError(response);
    final items = HttpResponseBody.requireList(response);

    return items.map((item) => FixtureModel.fromJson(item)).toList();
  }

  @override
  Future<FixtureDetailModel> getFixtureDetails({
    required String fixtureId,
  }) async {
    final response = await _httpService.get('/scores/match-details/$fixtureId');

    HttpResponseBody.throwIfHttpError(response);
    final item = HttpResponseBody.requireMap(response);

    return FixtureDetailModel.fromJson(item);
  }

  @override
  Future<FixtureLineupModel> getFixtureLineups({
    required String fixtureId,
  }) async {
    final response = await _httpService.get('/scores/match-lineups/$fixtureId');

    HttpResponseBody.throwIfHttpError(response);
    final item = HttpResponseBody.requireMap(response);

    return FixtureLineupModel.fromJson(item);
  }
}
