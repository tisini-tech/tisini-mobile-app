import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class SwapPlayersUsecase implements UseCase<List<Lineup>, SwapPlayersParams> {
  final MatchCaptureRepository repository;

  SwapPlayersUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Lineup>>> call(SwapPlayersParams params) async {
    return await repository.swapPlayers(
      teamId: params.teamId,
      fixtureId: params.fixtureId,
      players: params.players,
    );
  }
}

class SwapPlayersParams {
  final String teamId;
  final String fixtureId;
  final List<Map<String, int>> players;

  SwapPlayersParams({
    required this.teamId,
    required this.fixtureId,
    required this.players,
  });
}
