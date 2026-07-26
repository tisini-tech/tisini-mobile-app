import 'package:tisini/features/match_capture/domain/entities/match_subevent.dart';

class MatchSubEventModel extends MatchSubEvent {
  MatchSubEventModel({
    required super.id,
    required super.name,
    required super.metric,
    required super.strength,
    required super.isPlayer,
    required super.position,
  });

  factory MatchSubEventModel.fromJson(Map<String, dynamic> json) {
    return MatchSubEventModel(
      id: _string(json, const ['id']),
      name: _string(json, const ['name']),
      metric: _string(json, const ['metric']),
      strength: _string(json, const ['strength']),
      isPlayer: _bool(json['is_player'] ?? json['isPlayer']),
      position: _string(json, const ['position']),
    );
  }

  static String _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static bool _bool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    final s = value.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'metric': metric,
    'strength': strength,
    'isPlayer': isPlayer,
    'position': position,
  };

  @override
  String toString() => 'Subevent $id: $name (Position: $position)';
}
