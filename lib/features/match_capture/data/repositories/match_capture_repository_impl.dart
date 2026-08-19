import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_local_source.dart';
import 'package:tisini/features/match_capture/data/datasources/match_capture_remote_source.dart';
import 'package:tisini/features/match_capture/data/models/agent_arrival_model.dart';
import 'package:tisini/features/match_capture/data/models/event_category_model.dart';
import 'package:tisini/features/match_capture/data/models/match_event_model.dart';
import 'package:tisini/features/match_capture/data/models/metric_model.dart';
import 'package:tisini/features/match_capture/data/models/match_score_model.dart';
import 'package:tisini/features/match_capture/data/models/lineup_model.dart';
import 'package:tisini/features/match_capture/data/models/player_model.dart';
import 'package:tisini/features/match_capture/data/models/sop_model.dart';
import 'package:tisini/features/match_capture/domain/entities/agent_arrival.dart';
import 'package:tisini/features/match_capture/domain/entities/new_player_input.dart';
import 'package:tisini/features/match_capture/domain/entities/sop.dart';
import 'package:tisini/features/match_capture/domain/match_event_sync.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class MatchCaptureRepositoryImpl implements MatchCaptureRepository {
  final MatchCaptureRemoteSource remoteSource;
  final MatchCaptureLocalSource localSource;

  const MatchCaptureRepositoryImpl({
    required this.remoteSource,
    required this.localSource,
  });

  @override
  Future<Either<Failure, String>> uploadImage({required String path}) async {
    try {
      final data = await remoteSource.uploadImage(path: path);
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SopModel>> getSop({required String fixtureId}) async {
    try {
      final data = await remoteSource.getSop(fixtureId: fixtureId);
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sop>> createSop({
    required String fixtureId,
    required Sop sop,
  }) async {
    try {
      final data = await remoteSource.createSop(
        fixtureId: fixtureId,
        sop: SopModel.fromEntity(sop).toCreateJson(),
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sop>> updateSop({
    required String fixtureId,
    required String sopId,
    required Sop sop,
  }) async {
    try {
      final data = await remoteSource.updateSop(
        fixtureId: fixtureId,
        sopId: sopId,
        sop: SopModel.fromEntity(sop).toCreateJson(),
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AgentArrival>> getAgentArrival({
    required String fixtureId,
  }) async {
    try {
      final data = await remoteSource.getAgentArrival(fixtureId: fixtureId);
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AgentArrival>> createAgentArrival({
    required String fixtureId,
    required AgentArrival arrival,
  }) async {
    try {
      final data = await remoteSource.createAgentArrival(
        fixtureId: fixtureId,
        arrival: AgentArrivalModel.fromEntity(arrival).toCreateJson(),
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MetricModel>>> getMatchMetrics({
    required String fixtureType,
  }) async {
    try {
      final data = await remoteSource.getMatchMetrics(fixtureType: fixtureType);
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchEventModel>>> getMatchEvents({
    required String fixtureId,
    bool isCritical = false,
    bool isLastTen = false,
  }) async {
    try {
      final data = await remoteSource.getMatchEvents(
        fixtureId: fixtureId,
        isCritical: isCritical,
        isLastTen: isLastTen,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchEventCategoryModel>>>
  getMatchEventCategories({required String fixtureType}) async {
    try {
      final data = await remoteSource.getMatchEventCategories(
        fixtureType: fixtureType,
      );

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createMatchEvent({
    required String fixtureId,
    required bool addOwnGoal,
    required Map<String, dynamic> matchEvent,
  }) async {
    try {
      final data = await remoteSource.createMatchEvent(
        fixtureId: fixtureId,
        addOwnGoal: addOwnGoal,
        matchEvent: matchEvent,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEventModel>> updateMatchEvent({
    required String fixtureId,
    required String eventId,
    required Map<String, dynamic> matchEvent,
  }) async {
    try {
      final data = await remoteSource.updateMatchEvent(
        fixtureId: fixtureId,
        eventId: eventId,
        matchEvent: matchEvent,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteMatchEvent({
    required String fixtureId,
    required String eventId,
  }) async {
    try {
      final data = await remoteSource.deleteMatchEvent(
        fixtureId: fixtureId,
        eventId: eventId,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> startMatch({
    required String token,
    required String fixtureId,
  }) async {
    try {
      final data = await remoteSource.startMatch(
        token: token,
        fixtureId: fixtureId,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> endHalf({
    required String token,
    required String fixtureId,
    required String minute,
    required String second,
    required String status,
    required String moment,
  }) async {
    try {
      final data = await remoteSource.endHalf(
        token: token,
        fixtureId: fixtureId,
        minute: minute,
        second: second,
        status: status,
        moment: moment,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchScoreModel>> getMatchScore({
    required String fixtureId,
  }) async {
    try {
      final data = await remoteSource.getMatchScore(fixtureId: fixtureId);

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LineupModel>>> getTeamLineup({
    required String fixtureId,
    required String teamId,
  }) async {
    try {
      final data = await remoteSource.getTeamLineup(
        fixtureId: fixtureId,
        teamId: teamId,
      );

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LineupModel>>> swapPlayers({
    required String teamId,
    required String fixtureId,
    required List<Map<String, int>> players,
  }) async {
    try {
      final data = await remoteSource.swapPlayers(
        teamId: teamId,
        fixtureId: fixtureId,
        players: players,
      );

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TeamPlayerModel>>> getTeamPlayers({
    required String teamId,
  }) async {
    try {
      final data = await remoteSource.getTeamPlayers(teamId: teamId);

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TeamPlayerModel>> updateTeamPlayer({
    required String teamId,
    required String playerId,
    required Map<String, dynamic> player,
  }) async {
    try {
      final data = await remoteSource.updateTeamPlayer(
        teamId: teamId,
        playerId: playerId,
        player: player,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TeamPlayerModel>> addPlayer({
    required String teamId,
    required NewPlayerInput player,
  }) async {
    try {
      final message = await remoteSource.addPlayer(
        teamId: teamId,
        body: player.toJson(),
      );

      return Right(message);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LineupModel>>> saveLineup({
    required String token,
    required String fixtureId,
    required String teamId,
    required List<Map<String, dynamic>> lineups,
  }) async {
    try {
      final data = await remoteSource.saveLineup(
        token: token,
        fixtureId: fixtureId,
        teamId: teamId,
        lineups: lineups,
      );

      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<void> saveSubmittedEvents(
    String fixtureId,
    List<Map<String, dynamic>> events,
  ) async {
    await localSource.saveSubmittedEvents(fixtureId, events);
  }

  @override
  Future<List<Map<String, dynamic>>> getSubmittedEvents(String fixtureId) =>
      localSource.getSubmittedEvents(fixtureId);

  @override
  Future<Either<Failure, Map<String, dynamic>>> saveMatchEventLocally({
    required String fixtureId,
    required Map<String, dynamic> event,
  }) async {
    try {
      final saved = await localSource.saveMatchEventLocally(fixtureId, event);
      return Right(saved);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateMatchEventStatus({
    required String fixtureId,
    required String localId,
    required String status,
  }) async {
    try {
      final updated = await localSource.updateMatchEventStatus(
        fixtureId: fixtureId,
        localId: localId,
        status: status,
      );
      return Right(updated);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> syncPendingMatchEvents({
    required String fixtureId,
  }) async {
    try {
      final stored = await localSource.getSubmittedEvents(fixtureId);
      final pending = stored.where(MatchEventSync.isPendingSync).toList();

      if (pending.isEmpty) {
        return const Right('All events are already synced');
      }

      var uploaded = 0;
      for (final record in pending) {
        final localId = MatchEventSync.resolveLocalId(record);
        final payload = MatchEventSync.payloadForUpload(record, syncStatus: 1);

        try {
          await remoteSource.createMatchEvent(
            fixtureId: fixtureId,
            addOwnGoal: MatchEventSync.isOwnGoal(record),
            matchEvent: payload,
          );
          if (localId.isNotEmpty) {
            await localSource.updateMatchEventStatus(
              fixtureId: fixtureId,
              localId: localId,
              status: 'success',
            );
          }
          uploaded++;
        } on ServerException catch (e) {
          if (localId.isNotEmpty) {
            await localSource.updateMatchEventStatus(
              fixtureId: fixtureId,
              localId: localId,
              status: 'failed',
            );
          }
          return Left(
            Failure(
              'Synced $uploaded of ${pending.length}. Last error: ${e.message}',
            ),
          );
        }
      }

      return Right('Synced $uploaded of ${pending.length} event(s)');
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
