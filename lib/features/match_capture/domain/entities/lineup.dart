import 'package:tisini/features/match_capture/domain/entities/player.dart';

class Lineup {
  final Player player;
  final int id;
  final int match;
  final int team;
  final int teamPlayer;
  final String role;
  final int lineupPosition;
  final int jerseyNumber;
  final bool isGoalkeeper;
  final bool isSentOff;
  final bool verified;
  final dynamic gameStrength;
  final dynamic rating;
  final int minutesPlayed;

  Lineup({
    required this.player,
    required this.id,
    required this.match,
    required this.team,
    required this.teamPlayer,
    required this.role,
    required this.lineupPosition,
    required this.jerseyNumber,
    required this.isGoalkeeper,
    required this.isSentOff,
    required this.verified,
    required this.gameStrength,
    required this.rating,
    required this.minutesPlayed,
  });
}
