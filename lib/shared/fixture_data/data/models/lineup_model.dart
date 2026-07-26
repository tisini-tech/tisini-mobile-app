import 'package:tisini/shared/fixture_data/domain/entities/lineup.dart';

class LineupModel extends Lineup {
  LineupModel({
    required super.id,
    required super.fixtureId,
    required super.dateCreated,
    required super.teamPlayerId,
    required super.jerseyNo,
    required super.playerType,
    required super.player,
    required super.teamid,
    required super.pname,
    required super.lastUpdated,
    required super.lineupposition,
    required super.red,
    required super.gk,
    required super.passportphoto,
    required super.gameStrength,
  });

  factory LineupModel.fromJson(Map<String, dynamic> json) {
    return LineupModel(
      id: json['id']?.toString() ?? '',
      fixtureId: json['fixture_id']?.toString() ?? '', // Changed to fixture_id
      dateCreated: _parseDateTime(
        json['date_created'],
      ), // Changed to date_created
      teamPlayerId:
          json['team_player_id']?.toString() ?? '', // Changed to team_player_id
      jerseyNo: (json['Jersey_No'] ?? json['jersey_no'])?.toString() ?? '',
      playerType:
          json['player_type']?.toString() ?? '', // Changed to player_type
      pname: json['pname']?.toString() ?? '',
      lastUpdated: _parseDateTime(
        json['last_updated'],
      ), // Changed to last_updated
      lineupposition: json['lineupposition']?.toString() ?? '',
      red: json['red']?.toString() ?? '0',
      gk: (json['GK'] ?? json['gk'])?.toString() ?? '0',
      passportphoto: json['passportphoto']?.toString() ?? '',
      gameStrength: json['game_strength']?.toInt() ?? 0,
      player: json['player']?.toString() ?? '',
      teamid: json['teamid']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fixture_id': fixtureId, // Changed to fixture_id
      'date_created': dateCreated.toIso8601String(), // Changed to date_created
      'team_player_id': teamPlayerId, // Changed to team_player_id
      'Jersey_No': jerseyNo, // Changed to Jersey_No
      'player_type': playerType, // Changed to player_type
      'player': player, // Changed to player
      'teamid': teamid, // Changed to teamid
      'pname': pname,
      'last_updated': lastUpdated.toIso8601String(), // Changed to last_updated
      'lineupposition': lineupposition,
      'red': red,
      'GK': gk, // Changed to GK
      'passportphoto': passportphoto, // Changed to passportphoto
      'game_strength': gameStrength, // Changed to game_strength
    };
  }

  @override
  String toString() {
    return '{id: $id, name: "$pname", position: $lineupposition, jersey: $jerseyNo, fixtureId: $fixtureId}';
  }

  LineupModel copyWith({
    String? id,
    String? fixtureId,
    DateTime? dateCreated,
    String? teamPlayerId,
    String? jerseyNo,
    String? playerType,
    String? player,
    String? teamid,
    String? pname,
    DateTime? lastUpdated,
    String? lineupposition,
    String? red,
    String? gk,
    String? passportphoto,
    int? gameStrength,
  }) {
    return LineupModel(
      id: id ?? this.id,
      fixtureId: fixtureId ?? this.fixtureId,
      dateCreated: dateCreated ?? this.dateCreated,
      teamPlayerId: teamPlayerId ?? this.teamPlayerId,
      jerseyNo: jerseyNo ?? this.jerseyNo,
      playerType: playerType ?? this.playerType,
      player: player ?? this.player,
      teamid: teamid ?? this.teamid,
      pname: pname ?? this.pname,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lineupposition: lineupposition ?? this.lineupposition,
      red: red ?? this.red,
      gk: gk ?? this.gk,
      passportphoto: passportphoto ?? this.passportphoto,
      gameStrength: gameStrength ?? this.gameStrength,
    );
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      // Handle your specific date format "2025-08-05 15:55:36"
      return DateTime.tryParse(date.replaceAll(' ', 'T')) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
