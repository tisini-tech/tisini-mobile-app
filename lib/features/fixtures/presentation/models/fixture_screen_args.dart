/// Arguments model for FixturesScreen
/// Provides type safety when navigating to fixtures screen
class FixtureScreenArguments {
  final String fixtureType;
  final Map<String, dynamic>? filters;
  final String? leagueId;

  const FixtureScreenArguments({
    required this.fixtureType,
    this.filters,
    this.leagueId,
  });

  // Helper factory for common fixture types
  factory FixtureScreenArguments.football({Map<String, dynamic>? filters, String? leagueId}) {
    return FixtureScreenArguments(
      fixtureType: 'football',
      filters: filters,
      leagueId: leagueId,
    );
  }

  factory FixtureScreenArguments.rugby({Map<String, dynamic>? filters, String? leagueId}) {
    return FixtureScreenArguments(
      fixtureType: 'rugby',
      filters: filters,
      leagueId: leagueId,
    );
  }
}
