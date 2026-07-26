class TeamPlayer {
  final Player player;
  final int id;
  final int team;
  final int currentJerseyNo;

  TeamPlayer({
    required this.player,
    required this.id,
    required this.team,
    required this.currentJerseyNo,
  });
}

class Player {
  final String name;
  final int id;
  final String currentPosition;
  final String passportphoto;
  final dynamic fifaId;
  final dynamic preferredFoot;
  final String nationality;

  Player({
    required this.name,
    required this.id,
    required this.currentPosition,
    required this.passportphoto,
    required this.fifaId,
    required this.preferredFoot,
    required this.nationality,
  });
}
