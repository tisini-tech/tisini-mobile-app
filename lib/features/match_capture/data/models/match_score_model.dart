import 'package:tisini/features/match_capture/domain/entities/match_score.dart';

class MatchScoreModel extends MatchScore {
  MatchScoreModel({required super.home, required super.away});

  MatchScoreModel copyWith({int? home, int? away}) =>
      MatchScoreModel(home: home ?? this.home, away: away ?? this.away);

  factory MatchScoreModel.fromEntity(MatchScore matchScore) =>
      MatchScoreModel(home: matchScore.home, away: matchScore.away);

  factory MatchScoreModel.fromJson(Map<String, dynamic> json) {
    return MatchScoreModel(
      home: _parseInt(json['home_score'] ?? json['home']),
      away: _parseInt(json['away_score'] ?? json['away']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'home_score': home,
    'away_score': away,
  };
}
