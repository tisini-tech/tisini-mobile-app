import 'package:tisini/core/services/http_response_body.dart';
import 'package:tisini/core/services/http_service.dart';
import 'package:tisini/features/fixtures/data/models/agent_fixture_model.dart';

abstract interface class AgentFixtureRemoteSource {
  Future<List<AgentFixtureModel>> getAgentFixtures({required String token});
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
}
