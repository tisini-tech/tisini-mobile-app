import 'package:tisini/shared/fixture_data/domain/entities/match_player.dart';

class MatchPlayerModel {
  const MatchPlayerModel._();

  static MatchPlayer fromJson(Map<String, dynamic> json) {
    return MatchPlayer(
      id: json['id']?.toString() ?? '',
      fixtureId: json['fixture_id']?.toString() ?? '',
      teamPlayerId: json['team_player_id']?.toString() ?? '',
      jerseyNo: json['Jersey_No']?.toString() ?? '',
      playerType: json['player_type']?.toString() ?? '',
      playerId: json['player_id']?.toString() ?? '',
      teamId: json['teamId']?.toString() ?? '',
      pname: json['pname']?.toString() ?? '',
      lineupposition: json['lineupposition']?.toString() ?? '',
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'].toString())
          : DateTime.now(),
    );
  }
}
