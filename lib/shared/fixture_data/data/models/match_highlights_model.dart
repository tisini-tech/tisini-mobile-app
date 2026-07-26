import 'package:tisini/shared/fixture_data/domain/entities/match_highlights.dart';

class MatchHighlightsModel {
  const MatchHighlightsModel._();

  static MatchHighlights fromJson(Map<String, dynamic> json) {
    return MatchHighlights(
      eventName: json['event_name']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      team: json['team']?.toString() ?? '',
      gameid: json['gameid']?.toString() ?? '',
      playerId: json['player_id']?.toString() ?? '',
      subeventName: json['subeventName']?.toString() ?? '',
      subplayerName: json['subplayer_name']?.toString() ?? '',
      gameMinute: json['game_minute']?.toString() ?? '',
      gameSecond: json['game_second']?.toString() ?? '',
      gameMoment: json['game_moment']?.toString() ?? '',
      playerType: json['player_type']?.toString() ?? '',
      pname: json['pname']?.toString() ?? '',
      jerseyNo: json['Jersey_No']?.toString() ?? '',
    );
  }
}
