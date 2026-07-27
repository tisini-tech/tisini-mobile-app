import 'package:tisini/core/services/http_response_body.dart';
import 'package:tisini/core/services/http_service.dart';
import 'package:tisini/features/fixtures/data/models/agent_fixture_model.dart';

abstract interface class AgentFixtureRemoteSource {
  Future<List<AgentFixtureModel>> getAgentFixtures({required String token});

  Future<String> deactivateMatch({required String matchId});
}

class AgentFixtureRemoteSourceImpl implements AgentFixtureRemoteSource {
  final HttpService _httpService;

  AgentFixtureRemoteSourceImpl({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  @override
  Future<List<AgentFixtureModel>> getAgentFixtures({
    required String token,
  }) async {
    final response = await _httpService.get('/agent-fixtures');

    HttpResponseBody.throwIfHttpError(
      response,
      fallback: 'Failed to load agent fixtures',
    );

    final items = HttpResponseBody.requireList(response);

    return items.map(AgentFixtureModel.fromJson).toList();
  }

  @override
  Future<String> deactivateMatch({required String matchId}) async {
    final response = await _httpService.patch('/fixtures/$matchId', {
      'status': 'inactive',
    });

    print(response.data);

    HttpResponseBody.throwIfHttpError(
      response,
      fallback: 'Failed to deactivate match',
    );

    return 'fixture deactivated';
  }
}
