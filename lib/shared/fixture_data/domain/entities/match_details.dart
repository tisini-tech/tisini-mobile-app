/// Domain entity: match/fixture header details.
class MatchDetails {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final DateTime gameDate;
  final String homeTeam;
  final String awayTeam;
  final String gameStatus;
  final String minute;
  final String second;
  final String gameMoment;
  final String league;
  final String matchday;
  final String fixtureType;
  final String live;
  final String teamView;
  final String series;
  final String leagueId;

  const MatchDetails({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.gameDate,
    required this.homeTeam,
    required this.awayTeam,
    required this.gameStatus,
    required this.minute,
    required this.second,
    required this.gameMoment,
    required this.league,
    required this.matchday,
    required this.fixtureType,
    required this.live,
    required this.teamView,
    required this.series,
    required this.leagueId,
  });
}
