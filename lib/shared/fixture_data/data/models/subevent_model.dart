import 'package:tisini/shared/fixture_data/domain/entities/sub_event_data.dart';

class SubEventDataModel extends SubEventData {
  SubEventDataModel({
    required super.subeventId,
    required super.subeventName,
    required super.homeCount,
    required super.awayCount,
  });

  SubEventDataModel copyWith({
    int? subeventId,
    String? subeventName,
    int? homeCount,
    int? awayCount,
  }) {
    return SubEventDataModel(
      subeventId: subeventId ?? this.subeventId,
      subeventName: subeventName ?? this.subeventName,
      homeCount: homeCount ?? this.homeCount,
      awayCount: awayCount ?? this.awayCount,
    );
  }

  factory SubEventDataModel.fromJson(Map<String, dynamic> json) {
    return SubEventDataModel(
      subeventId: _parseInt(json['subevent_id']),
      subeventName: json['subevent_name']?.toString() ?? '',
      homeCount: _parseInt(json['home_count']),
      awayCount: _parseInt(json['away_count']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'subevent_id': subeventId,
      'subevent_name': subeventName,
      'home_count': homeCount,
      'away_count': awayCount,
    };
  }
}
