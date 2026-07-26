import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/shared/fixture_data/domain/entities/fixture_data.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_data.dart';

abstract interface class FixtureDataRepository {
  Future<Either<Failure, FixtureData>> getFixtureData({
    required String fixtureId,
  });

  Future<Either<Failure, List<MatchData>>> getMatchData({
    required String fixtureId,
  });
}
