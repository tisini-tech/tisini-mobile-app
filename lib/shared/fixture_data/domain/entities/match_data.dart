import 'package:tisini/shared/fixture_data/domain/entities/sub_event_data.dart';

class MatchData {
  int eventId;
  String eventName;
  int homeCount;
  int awayCount;
  List<SubEventData> subEvents;

  MatchData({
    required this.eventId,
    required this.eventName,
    required this.homeCount,
    required this.awayCount,
    required this.subEvents,
  });
}
