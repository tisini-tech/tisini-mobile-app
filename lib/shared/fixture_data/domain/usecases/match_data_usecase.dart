import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_data.dart';
import 'package:tisini/shared/fixture_data/domain/repositories/fixture_data_repository.dart';

class GetMatchDataUsecase
    implements UseCase<List<MatchData>, GetMatchDataParams> {
  final FixtureDataRepository repository;

  GetMatchDataUsecase({required this.repository});

  @override
  Future<Either<Failure, List<MatchData>>> call(
    GetMatchDataParams params,
  ) async {
    return await repository.getMatchData(fixtureId: params.fixtureId);
  }
}

class GetMatchDataParams {
  final String fixtureId;

  GetMatchDataParams({required this.fixtureId});
}
