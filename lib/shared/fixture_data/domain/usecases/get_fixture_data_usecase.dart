import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/shared/fixture_data/domain/entities/fixture_data.dart';
import 'package:tisini/shared/fixture_data/domain/repositories/fixture_data_repository.dart';

class GetFixtureDataUsecase
    implements UseCase<FixtureData, GetFixtureDataParams> {
  final FixtureDataRepository repository;

  GetFixtureDataUsecase({required this.repository});

  @override
  Future<Either<Failure, FixtureData>> call(GetFixtureDataParams params) async {
    return await repository.getFixtureData(fixtureId: params.fixtureId);
  }
}

class GetFixtureDataParams {
  final String fixtureId;

  GetFixtureDataParams({required this.fixtureId});
}
