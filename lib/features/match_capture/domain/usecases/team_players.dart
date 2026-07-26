import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';
import 'package:tisini/features/match_capture/domain/entities/player.dart';

class TeamPlayersUsecase
    implements UseCase<List<TeamPlayer>, TeamPlayersParams> {
  final MatchCaptureRepository repository;

  TeamPlayersUsecase({required this.repository});

  @override
  Future<Either<Failure, List<TeamPlayer>>> call(
    TeamPlayersParams params,
  ) async {
    return await repository.getTeamPlayers(teamId: params.teamId);
  }
}

class TeamPlayersParams {
  final String teamId;

  TeamPlayersParams({required this.teamId});
}

class UpdateTeamPlayerUsecase
    implements UseCase<TeamPlayer, UpdateTeamPlayerParams> {
  final MatchCaptureRepository repository;

  UpdateTeamPlayerUsecase({required this.repository});

  @override
  Future<Either<Failure, TeamPlayer>> call(
    UpdateTeamPlayerParams params,
  ) async {
    return await repository.updateTeamPlayer(
      teamId: params.teamId,
      playerId: params.playerId,
      player: params.player,
    );
  }
}

class UpdateTeamPlayerParams {
  final String teamId;
  final String playerId;
  final Map<String, dynamic> player;

  UpdateTeamPlayerParams({
    required this.teamId,
    required this.playerId,
    required this.player,
  });
}
