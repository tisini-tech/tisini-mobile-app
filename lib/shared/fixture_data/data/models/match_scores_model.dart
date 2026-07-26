import 'package:tisini/shared/fixture_data/domain/entities/match_scores.dart';

class MatchScoresModel {
  const MatchScoresModel._();

  static String _firstNonEmpty(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final v = json[key];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '0';
  }

  static MatchScores fromJson(Map<String, dynamic> json) {
    return MatchScores(
      home: _firstNonEmpty(json, [
        'Home',
        'home',
        'HOME',
        'home_score',
        'team1',
        'Team1',
        'team1_score',
        'h',
        'H',
      ]),
      away: _firstNonEmpty(json, [
        'Away',
        'away',
        'AWAY',
        'away_score',
        'team2',
        'Team2',
        'team2_score',
        'a',
        'A',
      ]),
    );
  }
}
