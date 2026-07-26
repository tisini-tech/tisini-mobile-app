class MatchEventCategory {
  final FixtureType fixtureType;
  final int id;
  final String name;
  final int ranker;

  MatchEventCategory({
    required this.fixtureType,
    required this.id,
    required this.name,
    required this.ranker,
  });
}

class FixtureType {
  final int id;
  final String typeCode;
  final String typeName;

  FixtureType({
    required this.id,
    required this.typeCode,
    required this.typeName,
  });
}
