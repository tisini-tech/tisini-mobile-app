class AgentFixture {
  final int id;
  final int team1Id;
  final String team1Name;
  final int team2Id;
  final String team2Name;
  final dynamic homeScore;
  final dynamic awayScore;
  final String matchday;
  final String status;
  final DateTime gameDate;
  final String matchtime;
  final String gameMoment;
  final String gameStatus;
  final String teamview;
  final int minute;
  final int second;
  final String fixtureType;
  final int hybrid;
  final dynamic hybridhome;
  final dynamic hybridaway;
  final dynamic location;
  final dynamic pitchname;
  final int formation1;
  final int formation2;
  final String quarter;

  AgentFixture({
    required this.id,
    required this.team1Id,
    required this.team1Name,
    required this.team2Id,
    required this.team2Name,
    required this.homeScore,
    required this.awayScore,
    required this.matchday,
    required this.status,
    required this.gameDate,
    required this.matchtime,
    required this.gameMoment,
    required this.gameStatus,
    required this.teamview,
    required this.minute,
    required this.second,
    required this.fixtureType,
    required this.hybrid,
    required this.hybridhome,
    required this.hybridaway,
    required this.location,
    required this.pitchname,
    required this.formation1,
    required this.formation2,
    required this.quarter,
  });
}
