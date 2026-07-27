import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/fixtures/data/datasources/agent_fixture_remote_source.dart';
import 'package:tisini/features/fixtures/data/models/agent_fixture_model.dart';
import 'package:tisini/features/fixtures/domain/repositories/agent_fixture_repository.dart';

class AgentFixtureRepositoryImpl implements AgentFixtureRepository {
  final AgentFixtureRemoteSource remoteSource;

  const AgentFixtureRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, List<AgentFixtureModel>>> getAgentFixtures({
    required String token,
  }) async {
    try {
      final data = await remoteSource.getAgentFixtures(token: token);

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deactivateMatch({
    required String matchId,
  }) async {
    try {
      final result = await remoteSource.deactivateMatch(matchId: matchId);

      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
