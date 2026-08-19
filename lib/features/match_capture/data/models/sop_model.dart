import 'dart:convert';

import 'package:tisini/features/match_capture/domain/entities/sop.dart';

class SopModel extends Sop {
  const SopModel({
    super.id,
    super.match,
    super.sop,
    super.homeLineupImg,
    super.awayLineupImg,
    super.refDataImg,
    super.refDataJson,
    super.homeLineupAt,
    super.awayLineupAt,
    super.refDataAt,
    super.corrections,
    super.weather,
    super.createdBy,
    super.dateCreated,
    super.dateUpdated,
  });

  factory SopModel.fromEntity(Sop entity) => SopModel(
    id: entity.id,
    match: entity.match,
    sop: List<String>.from(entity.sop),
    homeLineupImg: entity.homeLineupImg,
    awayLineupImg: entity.awayLineupImg,
    refDataImg: entity.refDataImg,
    refDataJson: Map<String, dynamic>.from(entity.refDataJson),
    homeLineupAt: entity.homeLineupAt,
    awayLineupAt: entity.awayLineupAt,
    refDataAt: entity.refDataAt,
    corrections: List<String>.from(entity.corrections),
    weather: entity.weather,
    createdBy: entity.createdBy,
    dateCreated: entity.dateCreated,
    dateUpdated: entity.dateUpdated,
  );

  factory SopModel.fromJson(Map<String, dynamic> json) {
    return SopModel(
      id: _toInt(json['id']),
      match: _toInt(json['match']),
      sop: _displayList(json['sop']),
      homeLineupImg: (json['home_lineup_img'] ?? '').toString(),
      awayLineupImg: (json['away_lineup_img'] ?? '').toString(),
      refDataImg: (json['ref_data_img'] ?? '').toString(),
      refDataJson: json['ref_data_json'] is Map
          ? Map<String, dynamic>.from(json['ref_data_json'] as Map)
          : const {},
      homeLineupAt: _parseDate(json['home_lineup_at']),
      awayLineupAt: _parseDate(json['away_lineup_at']),
      refDataAt: _parseDate(json['ref_data_at']),
      corrections: _displayList(json['corrections']),
      weather: (json['weather'] ?? '').toString(),
      createdBy: _toInt(json['created_by']),
      dateCreated: _parseDate(json['date_created']),
      dateUpdated: _parseDate(json['date_updated']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'sop': sop,
      'home_lineup_img': homeLineupImg,
      'away_lineup_img': awayLineupImg,
      'ref_data_img': refDataImg,
      'ref_data_json': refDataJson,
      'home_lineup_at': homeLineupAt?.toUtc().toIso8601String(),
      'away_lineup_at': awayLineupAt?.toUtc().toIso8601String(),
      'ref_data_at': refDataAt?.toUtc().toIso8601String(),
      'corrections': corrections,
      'weather': weather,
    };
  }

  /// Accepts `["a"]`, `{"0": "a"}`, or `{"note": "a"}`.
  static List<String> _displayList(dynamic value) {
    if (value is List) {
      return [
        for (final item in value)
          if (_stringify(item).isNotEmpty) _stringify(item),
      ];
    }
    if (value is Map) {
      return [
        for (final entry in value.entries)
          if (_stringify(entry.value).isNotEmpty)
            int.tryParse(entry.key.toString()) != null
                ? _stringify(entry.value)
                : '${entry.key}: ${_stringify(entry.value)}',
      ];
    }
    final text = _stringify(value);
    return text.isEmpty ? const [] : [text];
  }

  static String _stringify(dynamic value) {
    if (value == null) return '';
    if (value is Map || value is List) {
      if (value is Map && value.isEmpty) return '';
      if (value is List && value.isEmpty) return '';
      return jsonEncode(value);
    }
    return value.toString().trim();
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
