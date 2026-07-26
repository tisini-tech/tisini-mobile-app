import 'package:tisini/shared/fixture_data/domain/entities/fixture_data.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_cards.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_details.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_fouls.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_scores.dart';
import 'package:tisini/shared/fixture_data/data/models/match_cards_model.dart';
import 'package:tisini/shared/fixture_data/data/models/match_details_model.dart';
import 'package:tisini/shared/fixture_data/data/models/match_events_model.dart';
import 'package:tisini/shared/fixture_data/data/models/match_fouls_model.dart';
import 'package:tisini/shared/fixture_data/data/models/match_highlights_model.dart';
import 'package:tisini/shared/fixture_data/data/models/match_player_model.dart';
import 'package:tisini/shared/fixture_data/data/models/match_scores_model.dart';

class FixtureDataModel {
  const FixtureDataModel._();

  /// Resolves the scores object from several possible API shapes.
  static Map<String, dynamic>? _scoresMap(Map<String, dynamic> json) {
    for (final key in ['scores', 'Scores', 'score']) {
      final v = json[key];
      if (v is Map && v.isNotEmpty) {
        return Map<String, dynamic>.from(v);
      }
    }
    final fixtureList = json['fixture'] as List<dynamic>?;
    if (fixtureList != null && fixtureList.isNotEmpty) {
      final first = fixtureList[0];
      if (first is Map) {
        final m = Map<String, dynamic>.from(first);
        for (final key in ['scores', 'Scores', 'score']) {
          final v = m[key];
          if (v is Map && v.isNotEmpty) {
            return Map<String, dynamic>.from(v);
          }
        }
      }
    }
    return null;
  }

  static FixtureData fromJson(Map<String, dynamic> json) {
    final fixtureList = json['fixture'] as List<dynamic>?;
    final matchDetails = fixtureList != null && fixtureList.isNotEmpty
        ? MatchDetailsModel.fromJson(
            Map<String, dynamic>.from(fixtureList[0] as Map),
          )
        : MatchDetails(
            id: '',
            homeTeamId: '',
            awayTeamId: '',
            gameDate: DateTime(1970),
            homeTeam: '',
            awayTeam: '',
            gameStatus: '',
            minute: '',
            second: '',
            gameMoment: '',
            league: '',
            matchday: '',
            fixtureType: '',
            live: '',
            teamView: '',
            series: '',
            leagueId: '',
          );

    final homeMap = json['home'] as Map<String, dynamic>? ?? {};
    final homeEvents = homeMap.entries
        .map(
          (e) => MatchEventsModel.fromJson(
            Map<String, dynamic>.from(e.value as Map),
          ),
        )
        .toList();

    final awayMap = json['away'] as Map<String, dynamic>? ?? {};
    final awayEvents = awayMap.entries
        .map(
          (e) => MatchEventsModel.fromJson(
            Map<String, dynamic>.from(e.value as Map),
          ),
        )
        .toList();

    final scoresMap = _scoresMap(json) ?? {};
    final matchScores = scoresMap.isNotEmpty
        ? MatchScoresModel.fromJson(scoresMap)
        : const MatchScores(home: '0', away: '0');

    final playersList = json['players'] as List<dynamic>? ?? [];
    final matchPlayers = playersList
        .map(
          (e) => MatchPlayerModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    final cardsMap = json['cards'] as Map<String, dynamic>? ?? {};
    final matchCards = cardsMap.isNotEmpty
        ? MatchCardsModel.fromJson(cardsMap)
        : const MatchCards(
            homered: 0,
            awayred: 0,
            homeyellow: 0,
            awayyellow: 0,
          );

    final foulsMap = json['fouls'] as Map<String, dynamic>? ?? {};
    final matchFouls = foulsMap.isNotEmpty
        ? MatchFoulsModel.fromJson(foulsMap)
        : const MatchFouls(
            homewon: 0,
            awaywon: 0,
            homecommitted: 0,
            awaycommitted: 0,
          );

    final gamedetailsList = json['gamedetails'] as List<dynamic>? ?? [];
    final matchHighlights = gamedetailsList
        .map(
          (e) => MatchHighlightsModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();

    return FixtureData(
      matchDetails: matchDetails,
      homeEvents: homeEvents,
      awayEvents: awayEvents,
      matchScores: matchScores,
      matchPlayers: matchPlayers,
      matchCards: matchCards,
      matchFouls: matchFouls,
      matchHighlights: matchHighlights,
    );
  }
}
