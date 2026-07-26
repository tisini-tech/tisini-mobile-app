import 'package:tisini/features/fixtures/domain/entities/fixture_lineup.dart';
import 'package:tisini/shared/fixture_data/data/models/lineup_model.dart';
import 'package:tisini/shared/fixture_data/domain/entities/lineup.dart';

class FixtureLineupModel extends FixtureLineups {
  FixtureLineupModel({required super.home, required super.away});

  factory FixtureLineupModel.fromJson(Map<String, dynamic> json) {
    return FixtureLineupModel(
      home: _parseLineups(json['home']),
      away: _parseLineups(json['away']),
    );
  }

  static List<Lineup> _parseLineups(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map(
          (item) => LineupModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'home': home.map((lineup) => (lineup as LineupModel).toJson()).toList(),
    'away': away.map((lineup) => (lineup as LineupModel).toJson()).toList(),
  };
}
