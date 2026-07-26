import 'package:tisini/features/match_capture/data/models/player_model.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/entities/player.dart';

class LineupModel extends Lineup {
  LineupModel({
    required super.player,
    required super.id,
    required super.match,
    required super.team,
    required super.teamPlayer,
    required super.role,
    required super.lineupPosition,
    required super.jerseyNumber,
    required super.isGoalkeeper,
    required super.isSentOff,
    required super.verified,
    required super.gameStrength,
    required super.rating,
    required super.minutesPlayed,
  });

  factory LineupModel.fromEntity(Lineup lineup) => LineupModel(
    player: lineup.player is PlayerModel
        ? lineup.player
        : PlayerModel.fromEntity(lineup.player),
    id: lineup.id,
    match: lineup.match,
    team: lineup.team,
    teamPlayer: lineup.teamPlayer,
    role: lineup.role,
    lineupPosition: lineup.lineupPosition,
    jerseyNumber: lineup.jerseyNumber,
    isGoalkeeper: lineup.isGoalkeeper,
    isSentOff: lineup.isSentOff,
    verified: lineup.verified,
    gameStrength: lineup.gameStrength,
    rating: lineup.rating,
    minutesPlayed: lineup.minutesPlayed,
  );

  factory LineupModel.fromJson(Map<String, dynamic> json) => LineupModel(
    player: _parsePlayer(json),
    id: _parseInt(json['id']),
    match: _parseInt(json['match'] ?? json['match_id'] ?? json['fixture_id']),
    team: _parseInt(json['team'] ?? json['team_id'] ?? json['teamId']),
    teamPlayer: _parseInt(json['team_player'] ?? json['team_player_id']),
    role: json['role']?.toString() ?? json['player_type']?.toString() ?? '',
    lineupPosition: _parseInt(
      json['lineup_position'] ?? json['lineupposition'],
    ),
    jerseyNumber: _parseInt(
      json['jersey_number'] ?? json['Jersey_No'] ?? json['jersey_no'],
    ),
    isGoalkeeper: _parseBool(json['is_goalkeeper'] ?? json['GK']),
    isSentOff: _parseBool(json['is_sent_off'] ?? json['red']),
    verified: _parseBool(json['verified'] ?? json['verify']),
    gameStrength: json['game_strength'],
    rating: json['rating'],
    minutesPlayed: _parseInt(json['minutes_played']),
  );

  static Player _parsePlayer(Map<String, dynamic> json) {
    final nested = json['player'];
    if (nested is Map<String, dynamic>) {
      return PlayerModel.fromJson(nested);
    }

    return PlayerModel.fromJson(json);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'match': match,
    'team': team,
    'team_player': teamPlayer,
    'role': role,
    'lineup_position': lineupPosition,
    'jersey_number': jerseyNumber,
    'is_goalkeeper': isGoalkeeper,
    'is_sent_off': isSentOff,
    'verified': verified,
    'game_strength': gameStrength,
    'rating': rating,
    'minutes_played': minutesPlayed,
    'player': player is PlayerModel
        ? (player as PlayerModel).toJson()
        : PlayerModel.fromEntity(player).toJson(),
  };

  LineupModel copyWith({
    Player? player,
    int? id,
    int? match,
    int? team,
    int? teamPlayer,
    String? role,
    int? lineupPosition,
    int? jerseyNumber,
    bool? isGoalkeeper,
    bool? isSentOff,
    bool? verified,
    dynamic gameStrength,
    dynamic rating,
    int? minutesPlayed,
  }) => LineupModel(
    player: player ?? this.player,
    id: id ?? this.id,
    match: match ?? this.match,
    team: team ?? this.team,
    teamPlayer: teamPlayer ?? this.teamPlayer,
    role: role ?? this.role,
    lineupPosition: lineupPosition ?? this.lineupPosition,
    jerseyNumber: jerseyNumber ?? this.jerseyNumber,
    isGoalkeeper: isGoalkeeper ?? this.isGoalkeeper,
    isSentOff: isSentOff ?? this.isSentOff,
    verified: verified ?? this.verified,
    gameStrength: gameStrength ?? this.gameStrength,
    rating: rating ?? this.rating,
    minutesPlayed: minutesPlayed ?? this.minutesPlayed,
  );

  @override
  String toString() =>
      '{id: $id, name: "${player.name}", role: $role, position: $lineupPosition, jersey: $jerseyNumber, match: $match}';

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool _parseBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return fallback;
  }
}
