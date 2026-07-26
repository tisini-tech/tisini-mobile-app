import 'package:tisini/features/fixtures/domain/entities/fixture.dart';

class FixtureDetails {
  final Fixture fixture;
  final Stats stats;
  final List<Highlight> highlights;

  FixtureDetails({
    required this.fixture,
    required this.stats,
    required this.highlights,
  });
}

class Highlight {
  final int id;
  final String eventName;
  final int eventId;
  final String time;
  final int team;
  final int gameid;
  final String narration;
  final int playerId;
  final String subeventId;
  final String subplayerId;
  final String gameMinute;
  final String gameSecond;
  final String gameMoment;
  final String teamplayerId;
  final String playerType;
  final String pname;
  final String jerseyNo;
  final String subsubeventId;
  final String quarter;

  Highlight({
    required this.id,
    required this.eventName,
    required this.eventId,
    required this.time,
    required this.team,
    required this.gameid,
    required this.narration,
    required this.playerId,
    required this.subeventId,
    required this.subplayerId,
    required this.gameMinute,
    required this.gameSecond,
    required this.gameMoment,
    required this.teamplayerId,
    required this.playerType,
    required this.pname,
    required this.jerseyNo,
    required this.subsubeventId,
    required this.quarter,
  });
}

class Stats {
  final List<EventStats> home;
  final List<EventStats> away;

  Stats({required this.home, required this.away});
}

class EventStats {
  final int eventId;
  final String eventName;
  final int total;
  final List<SubEventStats> subEvents;

  EventStats({
    required this.eventId,
    required this.eventName,
    required this.total,
    required this.subEvents,
  });
}

class SubEventStats {
  final String subEventId;
  final String subEventName;
  final int total;

  SubEventStats({
    required this.subEventId,
    required this.subEventName,
    required this.total,
  });
}
