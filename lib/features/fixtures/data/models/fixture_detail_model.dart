import 'package:tisini/features/fixtures/data/models/fixture_model.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_detail.dart';

class FixtureDetailModel extends FixtureDetails {
  FixtureDetailModel({
    required super.fixture,
    required super.stats,
    required super.highlights,
  });

  factory FixtureDetailModel.fromJson(Map<String, dynamic> json) {
    return FixtureDetailModel(
      fixture: FixtureModel.fromJson(
        Map<String, dynamic>.from(json['fixture'] as Map),
      ),
      stats: StatsModel.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map),
      ),
      highlights: _parseHighlights(json['highlights']),
    );
  }

  static List<Highlight> _parseHighlights(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map(
          (item) => HighlightModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Map<String, dynamic> toJson() => {
    "fixture": _fixtureToJson(fixture),
    "stats": _statsToJson(stats),
    "highlights": highlights.map(_highlightToJson).toList(),
  };

  Map<String, dynamic> _fixtureToJson(Fixture fixture) {
    if (fixture is FixtureModel) return fixture.toJson();
    return {
      "id": fixture.id,
      "team1_id": fixture.team1Id,
      "team2_id": fixture.team2Id,
      "game_date": fixture.gameDate.toIso8601String(),
      "team1_name": fixture.team1Name,
      "team2_name": fixture.team2Name,
      "fixture_type": fixture.fixtureType,
      "game_status": fixture.gameStatus,
      "minute": fixture.minute,
      "second": fixture.second,
      "game_moment": fixture.gameMoment,
      "league": fixture.league,
      "home_score": fixture.homeScore,
      "away_score": fixture.awayScore,
      "matchday": fixture.matchday,
      "series": fixture.series,
      "matchtime": fixture.matchtime,
      "location_id": fixture.locationId,
      "team1_logo": fixture.team1Logo,
      "team2_logo": fixture.team2Logo,
      "venue": fixture.venue == null
          ? null
          : {
              "name": fixture.venue!.name,
              "county": fixture.venue!.county,
              "latitude": fixture.venue!.latitude,
              "longitude": fixture.venue!.longitude,
            },
    };
  }

  Map<String, dynamic> _statsToJson(Stats stats) {
    if (stats is StatsModel) return stats.toJson();
    return {
      "home": stats.home.map(_eventStatsToJson).toList(),
      "away": stats.away.map(_eventStatsToJson).toList(),
    };
  }

  Map<String, dynamic> _eventStatsToJson(EventStats event) {
    if (event is EventStatsModel) return event.toJson();
    return {
      "event_id": event.eventId,
      "event_name": event.eventName,
      "total": event.total,
      "sub_events": event.subEvents.map(_subEventStatsToJson).toList(),
    };
  }

  Map<String, dynamic> _subEventStatsToJson(SubEventStats subEvent) {
    if (subEvent is SubEventStatsModel) return subEvent.toJson();
    return {
      "sub_event_id": subEvent.subEventId,
      "sub_event_name": subEvent.subEventName,
      "total": subEvent.total,
    };
  }

  Map<String, dynamic> _highlightToJson(Highlight highlight) {
    if (highlight is HighlightModel) return highlight.toJson();
    return {
      "id": highlight.id,
      "event_name": highlight.eventName,
      "event_id": highlight.eventId,
      "time": highlight.time,
      "team": highlight.team,
      "gameid": highlight.gameid,
      "narration": highlight.narration,
      "player_id": highlight.playerId,
      "subevent_id": highlight.subeventId,
      "subplayer_id": highlight.subplayerId,
      "game_minute": highlight.gameMinute,
      "game_second": highlight.gameSecond,
      "game_moment": highlight.gameMoment,
      "teamplayer_id": highlight.teamplayerId,
      "player_type": highlight.playerType,
      "pname": highlight.pname,
      "jersey_no": highlight.jerseyNo,
      "subsubevent_id": highlight.subsubeventId,
      "quarter": highlight.quarter,
    };
  }
}

class StatsModel extends Stats {
  StatsModel({required super.home, required super.away});

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      home: _parseEventStats(json['home']),
      away: _parseEventStats(json['away']),
    );
  }

  static List<EventStats> _parseEventStats(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map(
          (item) => EventStatsModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Map<String, dynamic> toJson() => {
    "home": home.map((event) => (event as EventStatsModel).toJson()).toList(),
    "away": away.map((event) => (event as EventStatsModel).toJson()).toList(),
  };
}

class EventStatsModel extends EventStats {
  EventStatsModel({
    required super.eventId,
    required super.eventName,
    required super.total,
    required super.subEvents,
  });

  factory EventStatsModel.fromJson(Map<String, dynamic> json) {
    return EventStatsModel(
      eventId: _asInt(json['event_id']),
      eventName: json['event_name']?.toString() ?? '',
      total: _asInt(json['total']),
      subEvents: _parseSubEvents(json['sub_events']),
    );
  }

  static List<SubEventStats> _parseSubEvents(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map(
          (item) => SubEventStatsModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() => {
    "event_id": eventId,
    "event_name": eventName,
    "total": total,
    "sub_events": subEvents
        .map((subEvent) => (subEvent as SubEventStatsModel).toJson())
        .toList(),
  };
}

class SubEventStatsModel extends SubEventStats {
  SubEventStatsModel({
    required super.subEventId,
    required super.subEventName,
    required super.total,
  });

  factory SubEventStatsModel.fromJson(Map<String, dynamic> json) {
    return SubEventStatsModel(
      subEventId: json['sub_event_id']?.toString() ?? '',
      subEventName: json['sub_event_name']?.toString() ?? '',
      total: EventStatsModel._asInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    "sub_event_id": subEventId,
    "sub_event_name": subEventName,
    "total": total,
  };
}

class HighlightModel extends Highlight {
  HighlightModel({
    required super.id,
    required super.eventName,
    required super.eventId,
    required super.time,
    required super.team,
    required super.gameid,
    required super.narration,
    required super.playerId,
    required super.subeventId,
    required super.subplayerId,
    required super.gameMinute,
    required super.gameSecond,
    required super.gameMoment,
    required super.teamplayerId,
    required super.playerType,
    required super.pname,
    required super.jerseyNo,
    required super.subsubeventId,
    required super.quarter,
  });

  factory HighlightModel.fromJson(Map<String, dynamic> json) {
    return HighlightModel(
      id: EventStatsModel._asInt(json['id']),
      eventName: json['event_name']?.toString() ?? '',
      eventId: EventStatsModel._asInt(json['event_id']),
      time: json['time']?.toString() ?? '',
      team: EventStatsModel._asInt(json['team']),
      gameid: EventStatsModel._asInt(json['gameid']),
      narration: json['narration']?.toString() ?? '',
      playerId: EventStatsModel._asInt(json['player_id']),
      subeventId: json['subevent_id']?.toString() ?? '',
      subplayerId: json['subplayer_id']?.toString() ?? '',
      gameMinute: json['game_minute']?.toString() ?? '',
      gameSecond: json['game_second']?.toString() ?? '',
      gameMoment: json['game_moment']?.toString() ?? '',
      teamplayerId: json['teamplayer_id']?.toString() ?? '',
      playerType: json['player_type']?.toString() ?? '',
      pname: json['pname']?.toString() ?? '',
      jerseyNo: json['jersey_no']?.toString() ?? '',
      subsubeventId: json['subsubevent_id']?.toString() ?? '',
      quarter: json['quarter']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "event_name": eventName,
    "event_id": eventId,
    "time": time,
    "team": team,
    "gameid": gameid,
    "narration": narration,
    "player_id": playerId,
    "subevent_id": subeventId,
    "subplayer_id": subplayerId,
    "game_minute": gameMinute,
    "game_second": gameSecond,
    "game_moment": gameMoment,
    "teamplayer_id": teamplayerId,
    "player_type": playerType,
    "pname": pname,
    "jersey_no": jerseyNo,
    "subsubevent_id": subsubeventId,
    "quarter": quarter,
  };
}
