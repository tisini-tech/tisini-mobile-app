class MatchSubEvent {
  final String id;
  final String name;
  final String metric;
  final bool isPlayer;
  final String position;
  final String strength;

  MatchSubEvent({
    required this.id,
    required this.name,
    required this.metric,
    required this.strength,
    required this.isPlayer,
    required this.position,
  });
}
