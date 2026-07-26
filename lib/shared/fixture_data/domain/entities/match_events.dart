import 'package:tisini/shared/fixture_data/domain/entities/sub_event.dart';

class MatchEvents {
  final String name;
  final String eventId;
  final String total;
  final String team;
  final String gameid;
  final List<SubEvent> subEvents;

  const MatchEvents({
    required this.name,
    required this.eventId,
    required this.total,
    required this.team,
    required this.gameid,
    required this.subEvents,
  });
}
