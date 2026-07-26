import 'package:tisini/features/match_capture/domain/entities/event_category.dart';

class MatchEventCategoryModel extends MatchEventCategory {
  MatchEventCategoryModel({
    required super.fixtureType,
    required super.id,
    required super.name,
    required super.ranker,
  });

  factory MatchEventCategoryModel.fromJson(Map<String, dynamic> json) {
    return MatchEventCategoryModel(
      fixtureType: _parseFixtureType(json),
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      ranker: int.tryParse(json['ranker']?.toString() ?? '') ?? 0,
    );
  }

  static FixtureType _parseFixtureType(Map<String, dynamic> json) {
    final nested = json['fixture_type'];
    if (nested is Map) {
      return FixtureType(
        id: int.tryParse(nested['id']?.toString() ?? '') ?? 0,
        typeCode:
            (nested['type_code'] ?? nested['typeCode'])?.toString() ?? '',
        typeName:
            (nested['type_name'] ?? nested['typeName'])?.toString() ?? '',
      );
    }

    return FixtureType(
      id: int.tryParse(json['fixture_type_id']?.toString() ?? '') ?? 0,
      typeCode: json['fixture_type_code']?.toString() ?? '',
      typeName: json['fixture_type_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fixture_type_id': fixtureType.id,
      'fixture_type_code': fixtureType.typeCode,
      'fixture_type_name': fixtureType.typeName,
      'id': id,
      'name': name,
      'ranker': ranker,
    };
  }
}
