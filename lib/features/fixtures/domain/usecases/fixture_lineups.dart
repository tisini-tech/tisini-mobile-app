import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_lineup.dart';
import 'package:tisini/features/fixtures/domain/repositories/fixture_repository.dart';

class GetFixtureLineupsUsecase
    implements UseCase<FixtureLineups, GetFixtureLineupsParams> {
  final FixtureRepository repository;

  GetFixtureLineupsUsecase({required this.repository});

  @override
  Future<Either<Failure, FixtureLineups>> call(
    GetFixtureLineupsParams params,
  ) async {
    return await repository.getFixtureLineups(fixtureId: params.fixtureId);
  }
}

class GetFixtureLineupsParams {
  final String fixtureId;

  GetFixtureLineupsParams({required this.fixtureId});
}
