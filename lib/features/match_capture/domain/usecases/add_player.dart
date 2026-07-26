import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/new_player_input.dart';
import 'package:tisini/features/match_capture/domain/entities/player.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class AddPlayerUsecase implements UseCase<TeamPlayer, AddPlayerParams> {
  final MatchCaptureRepository repository;

  AddPlayerUsecase({required this.repository});

  @override
  Future<Either<Failure, TeamPlayer>> call(AddPlayerParams params) async {
    return repository.addPlayer(teamId: params.teamId, player: params.player);
  }
}

class AddPlayerParams {
  final String teamId;
  final NewPlayerInput player;

  AddPlayerParams({required this.teamId, required this.player});
}
