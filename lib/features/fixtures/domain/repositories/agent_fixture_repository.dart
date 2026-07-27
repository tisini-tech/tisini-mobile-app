import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';

abstract interface class AgentFixtureRepository {
  Future<Either<Failure, List<AgentFixture>>> getAgentFixtures({
    required String token,
  });

  Future<Either<Failure, String>> deactivateMatch({required String matchId});
}
