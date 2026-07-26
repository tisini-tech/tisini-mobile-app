import 'package:tisini/features/match_capture/domain/entities/metrics.dart';

class MetricModel extends Metric {
  MetricModel({
    required super.details,
    required super.subDetails,
    required super.id,
    required super.name,
    required super.fixtureType,
    required super.isPlayer,
    required super.isTimeline,
    required super.isTeam,
    required super.isActive,
    required super.gke,
    required super.closewindow,
    required super.uploaddata,
    required super.ref,
    required super.order,
    required super.metricCategory,
    required super.strength,
  });

  factory MetricModel.fromJson(Map<String, dynamic> json) {
    return MetricModel(
      details: (json['details'] as List? ?? [])
          .whereType<Map>()
          .map((e) => DetailModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      subDetails: (json['sub_details'] as List? ?? [])
          .whereType<Map>()
          .map((e) => SubDetailModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      fixtureType: _toInt(json['fixture_type']) ?? 0,
      isPlayer: _toInt(json['is_player']) ?? 0,
      isTimeline: _toInt(json['is_timeline']) ?? 0,
      isTeam: _toInt(json['is_team']) ?? 0,
      isActive: _toInt(json['is_active']) ?? 0,
      gke: _toInt(json['gke']) ?? 0,
      closewindow: _toInt(json['closewindow']) ?? 0,
      uploaddata: _toInt(json['uploaddata']) ?? 0,
      ref: _toInt(json['ref']),
      order: _toInt(json['order']) ?? 0,
      metricCategory: _toInt(json['metric_category']) ?? 0,
      strength: _toDouble(json['strength']),
    );
  }
}

class DetailModel extends Detail {
  DetailModel({
    required super.id,
    required super.name,
    required super.metric,
    required super.isPlayer,
    required super.position,
    required super.strength,
  });

  factory DetailModel.fromJson(Map<String, dynamic> json) {
    return DetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      metric: json['metric']?.toString() ?? '',
      isPlayer: _toBool(json['is_player']),
      position: json['position']?.toString() ?? '',
      strength: _toDouble(json['strength']),
    );
  }
}

class SubDetailModel extends SubDetail {
  SubDetailModel({
    required super.id,
    required super.name,
    required super.isPlayer,
    required super.position,
    required super.strength,
  });

  factory SubDetailModel.fromJson(Map<String, dynamic> json) {
    return SubDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isPlayer: _toBool(json['is_player']),
      position: json['position']?.toString() ?? '',
      strength: _toDouble(json['strength']),
    );
  }
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

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1';
}
