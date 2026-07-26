import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/fixtures/domain/repositories/fixture_repository.dart';

class GetFixtureDatesUsecase
    implements UseCase<List<String>, GetFixtureDatesParams> {
  final FixtureRepository fixtureRepository;

  GetFixtureDatesUsecase({required this.fixtureRepository});

  @override
  Future<Either<Failure, List<String>>> call(
    GetFixtureDatesParams params,
  ) async {
    return await fixtureRepository.getFixtureDates(
      fixtureType: params.fixtureType,
    );
  }
}

class GetFixtureDatesParams {
  final String fixtureType;

  GetFixtureDatesParams({required this.fixtureType});
}
