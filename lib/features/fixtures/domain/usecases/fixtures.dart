import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture.dart';
import 'package:tisini/features/fixtures/domain/repositories/fixture_repository.dart';

class GetFixturesUsecase implements UseCase<List<Fixture>, GetFixturesParams> {
  final FixtureRepository fixtureRepository;

  GetFixturesUsecase({required this.fixtureRepository});

  @override
  Future<Either<Failure, List<Fixture>>> call(GetFixturesParams params) async {
    return await fixtureRepository.getFixtures(
      matchDate: params.matchDate,
      fixtureType: params.fixtureType,
    );
  }
}

class GetFixturesParams {
  final String matchDate;
  final String fixtureType;

  GetFixturesParams({required this.matchDate, required this.fixtureType});
}
