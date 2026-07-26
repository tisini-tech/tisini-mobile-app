import 'package:tisini/shared/fixture_data/domain/entities/match_cards.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_details.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_events.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_fouls.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_highlights.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_player.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_scores.dart';

/// Domain entity: full fixture data (details, events, scores, players, etc.).
class FixtureData {
  final MatchDetails matchDetails;
  final List<MatchEvents> homeEvents;
  final List<MatchEvents> awayEvents;
  final MatchScores matchScores;
  final List<MatchPlayer> matchPlayers;
  final MatchCards matchCards;
  final MatchFouls matchFouls;
  final List<MatchHighlights> matchHighlights;

  const FixtureData({
    required this.matchDetails,
    required this.homeEvents,
    required this.awayEvents,
    required this.matchScores,
    required this.matchPlayers,
    required this.matchCards,
    required this.matchFouls,
    required this.matchHighlights,
  });
}
