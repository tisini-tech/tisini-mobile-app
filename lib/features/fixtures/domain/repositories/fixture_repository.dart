import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_detail.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_lineup.dart';

abstract interface class FixtureRepository {
  Future<Either<Failure, List<Fixture>>> getFixtures({
    required String matchDate,
    required String fixtureType,
  });

  Future<Either<Failure, List<String>>> getFixtureDates({
    required String fixtureType,
  });

  Future<Either<Failure, FixtureDetails>> getFixtureDetails({
    required String fixtureId,
  });

  Future<Either<Failure, FixtureLineups>> getFixtureLineups({
    required String fixtureId,
  });
}
