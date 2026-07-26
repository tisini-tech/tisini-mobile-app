class Lineup {
  final String id;
  final String fixtureId;
  final DateTime dateCreated;
  final String teamPlayerId;
  final String jerseyNo;
  final String playerType;
  final String player;
  final String teamid;
  final String pname;
  final DateTime lastUpdated;
  final String lineupposition;
  final String red;
  final String gk;
  final String passportphoto;
  final int gameStrength;

  Lineup({
    required this.id,
    required this.fixtureId,
    required this.dateCreated,
    required this.teamPlayerId,
    required this.jerseyNo,
    required this.playerType,
    required this.player,
    required this.teamid,
    required this.pname,
    required this.lastUpdated,
    required this.lineupposition,
    required this.red,
    required this.gk,
    required this.passportphoto,
    required this.gameStrength,
  });
}
