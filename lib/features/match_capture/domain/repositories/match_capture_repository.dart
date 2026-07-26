import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/match_capture/domain/entities/event_category.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/domain/entities/match_score.dart';
import 'package:tisini/features/match_capture/domain/entities/match_event.dart';
import 'package:tisini/features/match_capture/domain/entities/new_player_input.dart';
import 'package:tisini/features/match_capture/domain/entities/player.dart';

abstract interface class MatchCaptureRepository {
  Future<Either<Failure, List<Metric>>> getMatchMetrics({
    required String fixtureType,
  });

  Future<Either<Failure, List<MatchEventCategory>>> getMatchEventCategories({
    required String fixtureType,
  });

  Future<Either<Failure, List<MatchEvent>>> getMatchEvents({
    required String fixtureId,
    bool isCritical = false,
    bool isLastTen = false,
  });

  Future<Either<Failure, String>> createMatchEvent({
    required String fixtureId,
    required bool addOwnGoal,
    required Map<String, dynamic> matchEvent,
  });

  Future<Either<Failure, MatchEvent>> updateMatchEvent({
    required String fixtureId,
    required String eventId,
    required Map<String, dynamic> matchEvent,
  });

  Future<Either<Failure, String>> deleteMatchEvent({
    required String fixtureId,
    required String eventId,
  });

  Future<Either<Failure, String>> startMatch({
    required String token,
    required String fixtureId,
  });

  Future<Either<Failure, String>> endHalf({
    required String status,
    required String moment,
    required String minute,
    required String second,
    required String fixtureId,
    required String token,
  });

  Future<Either<Failure, MatchScore>> getMatchScore({
    required String fixtureId,
  });

  Future<Either<Failure, List<Lineup>>> getTeamLineup({
    required String fixtureId,
    required String teamId,
  });

  Future<Either<Failure, List<TeamPlayer>>> getTeamPlayers({
    required String teamId,
  });

  Future<Either<Failure, TeamPlayer>> updateTeamPlayer({
    required String teamId,
    required String playerId,
    required Map<String, dynamic> player,
  });

  Future<Either<Failure, TeamPlayer>> addPlayer({
    required String teamId,
    required NewPlayerInput player,
  });

  Future<Either<Failure, List<Lineup>>> saveLineup({
    required String token,
    required String fixtureId,
    required String teamId,
    required List<Map<String, dynamic>> lineups,
  });

  Future<Either<Failure, List<Lineup>>> swapPlayers({
    required String teamId,
    required String fixtureId,
    required List<Map<String, int>> players,
  });

  /// Persists submitted events for this fixture (local only).
  Future<void> saveSubmittedEvents(
    String fixtureId,
    List<Map<String, dynamic>> events,
  );

  /// Returns submitted events for this fixture from local storage (or empty).
  Future<List<Map<String, dynamic>>> getSubmittedEvents(String fixtureId);

  /// Appends one match event locally (payload + metadata). Returns saved record.
  Future<Either<Failure, Map<String, dynamic>>> saveMatchEventLocally({
    required String fixtureId,
    required Map<String, dynamic> event,
  });

  /// Persists upload outcome for a match event ([status]: pending | success | failed).
  Future<Either<Failure, Map<String, dynamic>>> updateMatchEventStatus({
    required String fixtureId,
    required String localId,
    required String status,
  });

  /// Uploads locally stored events that are not yet synced ([status] != success).
  /// Each payload is sent with `sync_status: 1`.
  Future<Either<Failure, String>> syncPendingMatchEvents({
    required String fixtureId,
  });
}
