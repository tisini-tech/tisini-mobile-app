import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/fixtures/domain/repositories/agent_fixture_repository.dart';

class AgentFixtures
    implements UseCase<List<AgentFixture>, AgentFixturesParams> {
  final AgentFixtureRepository agentFixtureRepository;

  AgentFixtures({required this.agentFixtureRepository});

  @override
  Future<Either<Failure, List<AgentFixture>>> call(
    AgentFixturesParams params,
  ) async {
    return await agentFixtureRepository.getAgentFixtures(token: params.token);
  }
}

class AgentFixturesParams {
  final String token;

  AgentFixturesParams({required this.token});
}
