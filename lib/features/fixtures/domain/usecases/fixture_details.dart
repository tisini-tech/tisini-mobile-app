import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_detail.dart';
import 'package:tisini/features/fixtures/domain/repositories/fixture_repository.dart';

class GetFixtureDetailsUsecase
    implements UseCase<FixtureDetails, GetFixtureDetailsParams> {
  final FixtureRepository repository;

  GetFixtureDetailsUsecase({required this.repository});

  @override
  Future<Either<Failure, FixtureDetails>> call(
    GetFixtureDetailsParams params,
  ) async {
    return await repository.getFixtureDetails(fixtureId: params.fixtureId);
  }
}

class GetFixtureDetailsParams {
  final String fixtureId;

  GetFixtureDetailsParams({required this.fixtureId});
}
