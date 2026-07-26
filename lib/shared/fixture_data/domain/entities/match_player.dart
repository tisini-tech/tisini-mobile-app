class MatchPlayer {
  final String id;
  final String fixtureId;
  final String teamPlayerId;
  final String jerseyNo;
  final String playerType;
  final String playerId;
  final String teamId;
  final String pname;
  final DateTime lastUpdated;
  final String lineupposition;

  const MatchPlayer({
    required this.id,
    required this.fixtureId,
    required this.teamPlayerId,
    required this.jerseyNo,
    required this.playerType,
    required this.playerId,
    required this.teamId,
    required this.pname,
    required this.lastUpdated,
    required this.lineupposition,
  });
}
