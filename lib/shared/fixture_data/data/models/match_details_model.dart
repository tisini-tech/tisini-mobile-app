import 'package:tisini/shared/fixture_data/domain/entities/match_details.dart';

class MatchDetailsModel {
  const MatchDetailsModel._();

  static MatchDetails fromJson(Map<String, dynamic> json) {
    return MatchDetails(
      id: json['id']?.toString() ?? '',
      homeTeamId: json['team1_id']?.toString() ?? '',
      awayTeamId: json['team2_id']?.toString() ?? '',
      gameDate: json['matchDate'] != null
          ? DateTime.parse(json['matchDate'].toString())
          : DateTime.now(),
      homeTeam: json['team1_name']?.toString() ?? '',
      awayTeam: json['team2_name']?.toString() ?? '',
      gameStatus: json['game_status']?.toString() ?? '',
      minute: json['minute']?.toString() ?? '',
      second: json['second']?.toString() ?? '',
      gameMoment: json['game_moment']?.toString() ?? '',
      league: json['league']?.toString() ?? '',
      matchday: json['matchday']?.toString() ?? '',
      fixtureType: json['fixture_type']?.toString() ?? '',
      live: json['live']?.toString() ?? '',
      teamView: json['teamview']?.toString() ?? '',
      series: json['series']?.toString() ?? '',
      leagueId: json['leagueid']?.toString() ?? '',
    );
  }
}
