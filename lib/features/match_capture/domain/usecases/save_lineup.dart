import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class SaveLineupUsecase implements UseCase<List<Lineup>, SaveLineupParams> {
  final MatchCaptureRepository repository;

  SaveLineupUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Lineup>>> call(SaveLineupParams params) async {
    return await repository.saveLineup(
      token: params.token,
      fixtureId: params.fixtureId,
      teamId: params.teamId,
      lineups: params.lineups,
    );
  }
}

class SaveLineupParams {
  final String token;
  final String fixtureId;
  final String teamId;
  final List<Map<String, dynamic>> lineups;

  SaveLineupParams({
    required this.token,
    required this.fixtureId,
    required this.teamId,
    required this.lineups,
  });
}
