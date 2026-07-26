import 'package:tisini/shared/fixture_data/domain/entities/match_cards.dart';

class MatchCardsModel {
  const MatchCardsModel._();

  static MatchCards fromJson(Map<String, dynamic> json) {
    return MatchCards(
      homered: (json['Homered'] as num?)?.toInt() ?? 0,
      awayred: (json['Awayred'] as num?)?.toInt() ?? 0,
      homeyellow: (json['Homeyellow'] as num?)?.toInt() ?? 0,
      awayyellow: (json['Awayyellow'] as num?)?.toInt() ?? 0,
    );
  }
}
