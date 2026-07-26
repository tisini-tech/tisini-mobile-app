import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class TeamLineupUsecase implements UseCase<List<Lineup>, TeamLineupParams> {
  final MatchCaptureRepository repository;

  TeamLineupUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Lineup>>> call(TeamLineupParams params) async {
    return await repository.getTeamLineup(
      fixtureId: params.fixtureId,
      teamId: params.teamId,
    );
  }
}

class TeamLineupParams {
  final String token;
  final String fixtureId;
  final String teamId;

  TeamLineupParams({
    required this.token,
    required this.fixtureId,
    required this.teamId,
  });
}
