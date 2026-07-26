import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/fixtures/data/datasources/fixture_remote_source.dart';
import 'package:tisini/features/fixtures/data/models/fixture_detail_model.dart';
import 'package:tisini/features/fixtures/data/models/fixture_lineup_model.dart';
import 'package:tisini/features/fixtures/data/models/fixture_model.dart';
import 'package:tisini/features/fixtures/domain/repositories/fixture_repository.dart';

class FixtureRepositoryImpl implements FixtureRepository {
  final FixtureRemoteSource remoteSource;

  const FixtureRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, List<String>>> getFixtureDates({
    required String fixtureType,
  }) async {
    try {
      final data = await remoteSource.getFixtureDates(fixtureType: fixtureType);

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FixtureModel>>> getFixtures({
    required String matchDate,
    required String fixtureType,
  }) async {
    try {
      final data = await remoteSource.getFixtures(
        matchDate: matchDate,
        fixtureType: fixtureType,
      );

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FixtureDetailModel>> getFixtureDetails({
    required String fixtureId,
  }) async {
    try {
      final data = await remoteSource.getFixtureDetails(fixtureId: fixtureId);

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FixtureLineupModel>> getFixtureLineups({
    required String fixtureId,
  }) async {
    try {
      final data = await remoteSource.getFixtureLineups(fixtureId: fixtureId);

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
