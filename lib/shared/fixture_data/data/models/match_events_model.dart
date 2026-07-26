import 'package:tisini/shared/fixture_data/domain/entities/match_events.dart';
import 'package:tisini/shared/fixture_data/data/models/sub_event_model.dart';

class MatchEventsModel {
  const MatchEventsModel._();

  static MatchEvents fromJson(Map<String, dynamic> json) {
    final subEventsList = json['sub-event'] as List<dynamic>? ?? [];
    final subEvents = subEventsList
        .map((e) => SubEventModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return MatchEvents(
      eventId: json['event_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      team: json['team']?.toString() ?? '',
      gameid: json['fixtureid']?.toString() ?? '',
      subEvents: subEvents,
    );
  }
}
