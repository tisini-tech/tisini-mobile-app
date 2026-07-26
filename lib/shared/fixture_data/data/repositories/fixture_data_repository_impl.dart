import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/shared/fixture_data/data/datasources/fixture_data_remote_source.dart';
import 'package:tisini/shared/fixture_data/data/models/fixture_data_model.dart';
import 'package:tisini/shared/fixture_data/domain/entities/fixture_data.dart';
import 'package:tisini/shared/fixture_data/domain/repositories/fixture_data_repository.dart';
import 'package:tisini/shared/fixture_data/data/models/match_data_model.dart';

class FixtureDataRepositoryImpl implements FixtureDataRepository {
  final FixtureDataRemoteSource remoteSource;

  FixtureDataRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, FixtureData>> getFixtureData({
    required String fixtureId,
  }) async {
    try {
      final json = await remoteSource.getFixtureData(fixtureId: fixtureId);
      final fixtureData = FixtureDataModel.fromJson(json);
      return Right(fixtureData);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchDataModel>>> getMatchData({
    required String fixtureId,
  }) async {
    try {
      final data = await remoteSource.getMatchData(fixtureId: fixtureId);

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
