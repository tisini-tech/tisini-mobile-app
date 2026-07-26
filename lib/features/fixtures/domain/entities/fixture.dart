class Fixture {
  final int id;
  final int team1Id;
  final int team2Id;
  final String team1Name;
  final String team2Name;
  final String homeScore;
  final String awayScore;
  final String matchday;
  final String league;
  final String series;
  final String fixtureType;
  final String gameStatus;
  final String gameMoment;
  final DateTime gameDate;
  final int minute;
  final int second;
  final String matchtime;
  final int locationId;
  final String team1Logo;
  final String team2Logo;
  final Venue? venue;
  final String homeHtScore;
  final String awayHtScore;
  final String homePenalties;
  final String awayPenalties;
  final String leagueName;
  final String seriesName;
  final String division;
  final String divisionName;
  final String stage;
  final String stageName;

  Fixture({
    required this.id,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
    required this.homeScore,
    required this.awayScore,
    required this.matchday,
    required this.league,
    required this.series,
    required this.fixtureType,
    required this.gameStatus,
    required this.gameMoment,
    required this.gameDate,
    required this.minute,
    required this.second,
    required this.matchtime,
    required this.locationId,
    required this.team1Logo,
    required this.team2Logo,
    required this.venue,
    required this.homeHtScore,
    required this.awayHtScore,
    required this.homePenalties,
    required this.awayPenalties,
    required this.leagueName,
    required this.seriesName,
    required this.division,
    required this.divisionName,
    required this.stage,
    required this.stageName,
  });
}

class Venue {
  final String name;
  final String county;
  final String latitude;
  final String longitude;

  Venue({
    required this.name,
    required this.county,
    required this.latitude,
    required this.longitude,
  });
}
