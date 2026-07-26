import 'package:tisini/shared/fixture_data/domain/entities/match_fouls.dart';

class MatchFoulsModel {
  const MatchFoulsModel._();

  static MatchFouls fromJson(Map<String, dynamic> json) {
    return MatchFouls(
      homewon: (json['Homewon'] as num?)?.toInt() ?? 0,
      awaywon: (json['Awaywon'] as num?)?.toInt() ?? 0,
      homecommitted: (json['Homecommitted'] as num?)?.toInt() ?? 0,
      awaycommitted: (json['Awaycommitted'] as num?)?.toInt() ?? 0,
    );
  }
}
