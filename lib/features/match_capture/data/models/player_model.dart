import 'package:tisini/features/match_capture/domain/entities/player.dart';

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class PlayerModel extends Player {
  PlayerModel({
    required super.name,
    required super.id,
    required super.currentPosition,
    required super.passportphoto,
    required super.fifaId,
    required super.preferredFoot,
    required super.nationality,
  });

  factory PlayerModel.fromEntity(Player player) => PlayerModel(
    name: player.name,
    id: player.id,
    currentPosition: player.currentPosition,
    passportphoto: player.passportphoto,
    fifaId: player.fifaId,
    preferredFoot: player.preferredFoot,
    nationality: player.nationality,
  );

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
    name: json['name']?.toString() ?? json['pname']?.toString() ?? '',
    id: _parseInt(json['id'] ?? json['player_id']),
    currentPosition:
        (json['current_position'] ?? json['currentPosition'])?.toString() ?? '',
    passportphoto: json['passportphoto']?.toString() ?? '',
    fifaId: json['fifa_id'] ?? json['fifaId'],
    preferredFoot: json['preferred_foot'] ?? json['preferredFoot'],
    nationality: json['nationality']?.toString() ?? '',
  );

  PlayerModel copyWith({
    String? name,
    int? id,
    String? currentPosition,
    String? passportphoto,
    dynamic fifaId,
    dynamic preferredFoot,
    String? nationality,
  }) => PlayerModel(
    name: name ?? this.name,
    id: id ?? this.id,
    currentPosition: currentPosition ?? this.currentPosition,
    passportphoto: passportphoto ?? this.passportphoto,
    fifaId: fifaId ?? this.fifaId,
    preferredFoot: preferredFoot ?? this.preferredFoot,
    nationality: nationality ?? this.nationality,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'current_position': currentPosition,
    'passportphoto': passportphoto,
    'fifa_id': fifaId,
    'preferred_foot': preferredFoot,
    'nationality': nationality,
  };
}

class TeamPlayerModel extends TeamPlayer {
  TeamPlayerModel({
    required super.player,
    required super.id,
    required super.team,
    required super.currentJerseyNo,
  });

  factory TeamPlayerModel.fromEntity(TeamPlayer teamPlayer) => TeamPlayerModel(
    player: teamPlayer.player is PlayerModel
        ? teamPlayer.player
        : PlayerModel.fromEntity(teamPlayer.player),
    id: teamPlayer.id,
    team: teamPlayer.team,
    currentJerseyNo: teamPlayer.currentJerseyNo,
  );

  factory TeamPlayerModel.fromJson(Map<String, dynamic> json) {
    final nestedPlayer = json['player'];
    final playerJson = nestedPlayer is Map<String, dynamic>
        ? nestedPlayer
        : json;

    return TeamPlayerModel(
      player: PlayerModel.fromJson(playerJson),
      id: _parseInt(json['id']),
      team: _parseInt(json['team_id'] ?? json['team']),
      currentJerseyNo: _parseInt(json['current_jersey_no']),
    );
  }

  TeamPlayerModel copyWith({
    Player? player,
    int? id,
    int? team,
    int? currentJerseyNo,
  }) => TeamPlayerModel(
    player: player ?? this.player,
    id: id ?? this.id,
    team: team ?? this.team,
    currentJerseyNo: currentJerseyNo ?? this.currentJerseyNo,
  );

  static const int substituteLineupPosition = 1000;

  /// Payload item for PATCH /fixtures/{id}/lineups/{team_id}.
  static Map<String, dynamic> lineupSavePayload({
    required TeamPlayer teamPlayer,
    required int teamId,
    required int lineupPosition,
    required String role,
    bool? isGoalkeeper,
  }) {
    final position = teamPlayer.player.currentPosition.toLowerCase();
    final goalkeeper =
        isGoalkeeper ??
        position.contains('goalkeeper') ||
            position == 'gk' ||
            position == 'goal keeper';

    return {
      'team_id': teamId,
      'player_id': teamPlayer.player.id,
      'team_player_id': teamPlayer.id,
      'role': role,
      'lineup_position': lineupPosition,
      'jersey_number': teamPlayer.currentJerseyNo,
      'is_goalkeeper': goalkeeper,
    };
  }

  /// Flat shape used by legacy endpoints.
  Map<String, dynamic> toJson() => {
    'id': id,
    'team_id': team,
    'current_jersey_no': currentJerseyNo,
    'player_id': player.id,
    'pname': player.name,
    'passportphoto': player.passportphoto,
    'current_position': player.currentPosition,
    'nationality': player.nationality,
    'player': player is PlayerModel
        ? (player as PlayerModel).toJson()
        : PlayerModel.fromEntity(player).toJson(),
  };
}
