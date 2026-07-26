import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';

class AgentFixtureModel extends AgentFixture {
  AgentFixtureModel({
    required super.id,
    required super.team1Id,
    required super.team1Name,
    required super.team2Id,
    required super.team2Name,
    required super.homeScore,
    required super.awayScore,
    required super.matchday,
    required super.status,
    required super.gameDate,
    required super.matchtime,
    required super.gameMoment,
    required super.gameStatus,
    required super.teamview,
    required super.minute,
    required super.second,
    required super.fixtureType,
    required super.hybrid,
    required super.hybridhome,
    required super.hybridaway,
    required super.location,
    required super.pitchname,
    required super.formation1,
    required super.formation2,
    required super.quarter,
  });

  AgentFixtureModel copyWith({
    int? id,
    int? team1Id,
    String? team1Name,
    int? team2Id,
    String? team2Name,
    dynamic homeScore,
    dynamic awayScore,
    String? matchday,
    String? status,
    DateTime? gameDate,
    String? matchtime,
    String? gameMoment,
    String? gameStatus,
    String? teamview,
    int? minute,
    int? second,
    String? fixtureType,
    int? hybrid,
    dynamic hybridhome,
    dynamic hybridaway,
    dynamic location,
    dynamic pitchname,
    int? formation1,
    int? formation2,
    String? quarter,
  }) => AgentFixtureModel(
    id: id ?? this.id,
    team1Id: team1Id ?? this.team1Id,
    team1Name: team1Name ?? this.team1Name,
    team2Id: team2Id ?? this.team2Id,
    team2Name: team2Name ?? this.team2Name,
    homeScore: homeScore ?? this.homeScore,
    awayScore: awayScore ?? this.awayScore,
    matchday: matchday ?? this.matchday,
    status: status ?? this.status,
    gameDate: gameDate ?? this.gameDate,
    matchtime: matchtime ?? this.matchtime,
    gameMoment: gameMoment ?? this.gameMoment,
    gameStatus: gameStatus ?? this.gameStatus,
    teamview: teamview ?? this.teamview,
    minute: minute ?? this.minute,
    second: second ?? this.second,
    fixtureType: fixtureType ?? this.fixtureType,
    hybrid: hybrid ?? this.hybrid,
    hybridhome: hybridhome ?? this.hybridhome,
    hybridaway: hybridaway ?? this.hybridaway,
    location: location ?? this.location,
    pitchname: pitchname ?? this.pitchname,
    formation1: formation1 ?? this.formation1,
    formation2: formation2 ?? this.formation2,
    quarter: quarter ?? this.quarter,
  );

  factory AgentFixtureModel.fromJson(Map<String, dynamic> json) =>
      AgentFixtureModel(
        id: _asInt(json["id"]),
        team1Id: _asInt(json["team1_id"]),
        team1Name: _asString(json["team1_name"]),
        team2Id: _asInt(json["team2_id"]),
        team2Name: _asString(json["team2_name"]),
        homeScore: _asInt(json["home_score"]),
        awayScore: _asInt(json["away_score"]),
        matchday: _asString(json["matchday"]),
        status: _asString(json["status"]),
        gameDate: _asDate(json["game_date"]),
        matchtime: _asString(json["matchtime"]),
        gameMoment: _asString(json["game_moment"]),
        gameStatus: _asString(json["game_status"]),
        teamview: _asString(json["teamview"]),
        minute: _asInt(json["minute"]),
        second: _asInt(json["second"]),
        fixtureType: _asString(json["fixture_type"]),
        hybrid: _asInt(json["hybrid"]),
        hybridhome: json["hybridhome"],
        hybridaway: json["hybridaway"],
        location: _asInt(json["location"]),
        pitchname: _asString(json["pitchname"]),
        formation1: _asInt(json["formation1"]),
        formation2: _asInt(json["formation2"]),
        quarter: _asString(json["quarter"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "team1_id": team1Id,
    "team1_name": team1Name,
    "team2_id": team2Id,
    "team2_name": team2Name,
    "home_score": homeScore,
    "away_score": awayScore,
    "matchday": matchday,
    "status": status,
    "game_date":
        "${gameDate.year.toString().padLeft(4, '0')}-${gameDate.month.toString().padLeft(2, '0')}-${gameDate.day.toString().padLeft(2, '0')}",
    "matchtime": matchtime,
    "game_moment": gameMoment,
    "game_status": gameStatus,
    "teamview": teamview,
    "minute": minute,
    "second": second,
    "fixture_type": fixtureType,
    "hybrid": hybrid,
    "hybridhome": hybridhome,
    "hybridaway": hybridaway,
    "location": location,
    "pitchname": pitchname,
    "formation1": formation1,
    "formation2": formation2,
    "quarter": quarter,
  };

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static DateTime _asDate(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970, 1, 1);
  }
}
