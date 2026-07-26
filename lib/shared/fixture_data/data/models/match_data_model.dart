import 'package:tisini/shared/fixture_data/domain/entities/match_data.dart';
import 'package:tisini/shared/fixture_data/data/models/subevent_model.dart';

class MatchDataModel extends MatchData {
  MatchDataModel({
    required super.eventId,
    required super.eventName,
    required super.homeCount,
    required super.awayCount,
    required super.subEvents,
  });

  MatchDataModel copyWith({
    int? eventId,
    String? eventName,
    int? homeCount,
    int? awayCount,
    List<SubEventDataModel>? subEvents,
  }) {
    return MatchDataModel(
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      homeCount: homeCount ?? this.homeCount,
      awayCount: awayCount ?? this.awayCount,
      subEvents: subEvents ?? this.subEvents,
    );
  }

  factory MatchDataModel.fromJson(Map<String, dynamic> json) {
    return MatchDataModel(
      eventId: _parseInt(json['event_id']),
      eventName: json['event_name']?.toString() ?? '',
      homeCount: _parseInt(json['home_count']),
      awayCount: _parseInt(json['away_count']),
      subEvents: _parseSubEvents(json['sub_events']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static List<SubEventDataModel> _parseSubEvents(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map(
          (e) => SubEventDataModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}
