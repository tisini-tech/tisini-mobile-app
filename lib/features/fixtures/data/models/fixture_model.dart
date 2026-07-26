import 'package:tisini/features/fixtures/domain/entities/fixture.dart';

class FixtureModel extends Fixture {
  FixtureModel({
    required super.id,
    required super.team1Id,
    required super.team2Id,
    required super.team1Name,
    required super.team2Name,
    required super.homeScore,
    required super.awayScore,
    required super.matchday,
    required super.league,
    required super.series,
    required super.fixtureType,
    required super.gameStatus,
    required super.gameMoment,
    required super.gameDate,
    required super.minute,
    required super.second,
    required super.matchtime,
    required super.locationId,
    required super.team1Logo,
    required super.team2Logo,
    required super.venue,
    required super.homeHtScore,
    required super.awayHtScore,
    required super.homePenalties,
    required super.awayPenalties,
    required super.leagueName,
    required super.seriesName,
    required super.division,
    required super.divisionName,
    required super.stage,
    required super.stageName,
  });

  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    return FixtureModel(
      id: _parseInt(json["id"]),
      team1Id: _parseInt(json["team1_id"]),
      team2Id: _parseInt(json["team2_id"]),
      team1Name: json["team1_name"].toString(),
      team2Name: json["team2_name"].toString(),
      homeScore: json["home_score"]?.toString() ?? '0',
      awayScore: json["away_score"]?.toString() ?? '0',
      matchday: json["matchday"]?.toString() ?? '',
      league: json["league"]?.toString() ?? '',
      series: json["series"]?.toString() ?? '',
      fixtureType: json["fixture_type"].toString(),
      gameStatus: json["game_status"].toString(),
      gameMoment: json["game_moment"].toString(),
      gameDate: _parseGameDate(json["game_date"]),
      minute: _parseInt(json["minute"]),
      second: _parseInt(json["second"]),
      matchtime: json["matchtime"]?.toString() ?? '',
      locationId: _parseInt(json["location_id"]),
      team1Logo: json["team1_logo"]?.toString() ?? '',
      team2Logo: json["team2_logo"]?.toString() ?? '',
      venue: json["venue"] is Map<String, dynamic>
          ? VenueModel.fromJson(json["venue"])
          : null,
      homeHtScore: json["home_ht_score"]?.toString() ?? '0',
      awayHtScore: json["away_ht_score"]?.toString() ?? '0',
      homePenalties: json["home_penalties"]?.toString() ?? '0',
      awayPenalties: json["away_penalties"]?.toString() ?? '0',
      leagueName: json["league_name"]?.toString() ?? '',
      seriesName: json["series_name"]?.toString() ?? '',
      division: json["division"]?.toString() ?? '',
      divisionName: json["division_name"]?.toString() ?? '',
      stage: json["stage"]?.toString() ?? '',
      stageName: json["stage_name"]?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime _parseGameDate(dynamic value) {
    if (value == null) return DateTime.now();
    final text = value.toString().trim();
    if (text.isEmpty) return DateTime.now();
    if (text.length <= 10) return DateTime.parse('${text}T00:00:00');
    return DateTime.parse(text.replaceFirst(' ', 'T'));
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "team1_id": team1Id,
    "team2_id": team2Id,
    "game_date": gameDate.toIso8601String(),
    "team1_name": team1Name,
    "team2_name": team2Name,
    "fixture_type": fixtureType,
    "game_status": gameStatus,
    "minute": minute,
    "second": second,
    "game_moment": gameMoment,
    "league": league,
    "home_score": homeScore,
    "away_score": awayScore,
    "matchday": matchday,
    "series": series,
    'matchtime': matchtime,
    'location_id': locationId,
    'team1_logo': team1Logo,
    'team2_logo': team2Logo,
    'venue': venue,
    'home_ht_score': homeHtScore,
    'away_ht_score': awayHtScore,
    'home_penalties': homePenalties,
    'away_penalties': awayPenalties,
    'league_name': leagueName,
    'series_name': seriesName,
    'division': division,
    'division_name': divisionName,
    'stage': stage,
    'stage_name': stageName,
  };
}

class VenueModel extends Venue {
  VenueModel({
    required super.name,
    required super.county,
    required super.latitude,
    required super.longitude,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      name: json["name"].toString(),
      county: json["county"].toString(),
      latitude: json["latitude"].toString(),
      longitude: json["longitude"].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "county": county,
    "latitude": latitude,
    "longitude": longitude,
  };
}
