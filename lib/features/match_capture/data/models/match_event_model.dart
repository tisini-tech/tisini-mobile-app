import 'package:tisini/features/match_capture/domain/entities/match_event.dart';

class MatchEventModel extends MatchEvent {
  MatchEventModel({
    required super.metric,
    required super.metricDetail,
    required super.metricSubDetail,
    required super.player,
    required super.subplayer,
    required super.agent,
    required super.id,
    required super.match,
    required super.team,
    required super.minute,
    required super.second,
    required super.moment,
    required super.quarter,
    required super.narration,
    required super.zoneId,
    required super.xper,
    required super.yper,
    required super.videoTimestamp,
    required super.noRuck,
    required super.noLineout,
    required super.meterGain,
    required super.kickfrom,
    required super.kickland,
    required super.defender,
    required super.strength,
    required super.localid,
    required super.appTimelog,
    required super.syncStatus,
  });

  factory MatchEventModel.fromJson(Map<String, dynamic> json) {
    return MatchEventModel(
      metric: SingleIdNameModel.fromJson(
        _asMap(json['metric']) ?? const <String, dynamic>{},
      ),
      metricDetail: SingleIdNameModel.maybeFromJson(json['metric_detail']),
      metricSubDetail: SingleIdNameModel.maybeFromJson(
        json['metric_sub_detail'],
      ),
      player: SingleIdNameModel.maybeFromJson(json['player']),
      subplayer: SingleIdNameModel.maybeFromJson(json['subplayer']),
      agent: SingleIdNameModel.maybeFromJson(json['agent']),
      id: _toInt(json['id']) ?? 0,
      match: _toInt(json['match']) ?? 0,
      team: _toInt(json['team']) ?? 0,
      minute: _toInt(json['minute']) ?? 0,
      second: _toInt(json['second']) ?? 0,
      moment: json['moment']?.toString() ?? '',
      quarter: json['quarter']?.toString() ?? '',
      narration: json['narration']?.toString() ?? '',
      zoneId: _toInt(json['zone_id']) ?? 0,
      xper: _toDouble(json['xper']),
      yper: _toDouble(json['yper']),
      videoTimestamp: _toInt(json['video_timestamp']) ?? 0,
      noRuck: _toInt(json['no_ruck']),
      noLineout: _toInt(json['no_lineout']),
      meterGain: _toDouble(json['meter_gain']),
      kickfrom: json['kickfrom']?.toString(),
      kickland: json['kickland']?.toString(),
      defender: json['defender']?.toString(),
      strength: _toDouble(json['strength']),
      localid: (json['localid'] ?? json['local_id'])?.toString() ?? '',
      appTimelog: json['app_timelog']?.toString() ?? '',
      syncStatus: _toInt(json['sync_status']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metric': SingleIdNameModel.toJsonMap(metric),
      'metric_detail': SingleIdNameModel.toJsonMap(metricDetail),
      'metric_sub_detail': SingleIdNameModel.toJsonMap(metricSubDetail),
      'player': SingleIdNameModel.toJsonMap(player),
      'subplayer': SingleIdNameModel.toJsonMap(subplayer),
      'agent': SingleIdNameModel.toJsonMap(agent),
      'id': id,
      'match': match,
      'team': team,
      'minute': minute,
      'second': second,
      'moment': moment,
      'quarter': quarter,
      'narration': narration,
      'zone_id': zoneId,
      'xper': xper,
      'yper': yper,
      'video_timestamp': videoTimestamp,
      'no_ruck': noRuck,
      'no_lineout': noLineout,
      'meter_gain': meterGain,
      'kickfrom': kickfrom,
      'kickland': kickland,
      'defender': defender,
      'strength': strength,
      'localid': localid,
      'app_timelog': appTimelog,
      'sync_status': syncStatus,
    };
  }
}

class SingleIdNameModel extends SingleIdName {
  const SingleIdNameModel({required super.id, required super.name});

  factory SingleIdNameModel.fromJson(Map<String, dynamic> json) {
    return SingleIdNameModel(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  static SingleIdNameModel? maybeFromJson(dynamic value) {
    final map = _asMap(value);
    if (map == null) return null;
    return SingleIdNameModel.fromJson(map);
  }

  static Map<String, dynamic>? toJsonMap(SingleIdName? value) {
    if (value == null) return null;
    return {'id': value.id, 'name': value.name};
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
