class PlayerPositions {
  static const String goalkeeper = 'Goalkeeper';
  static const String defender = 'Defender';
  static const String midfielder = 'Midfielder';
  static const String forward = 'Forward';

  static const String prop = 'Prop';
  static const String hooker = 'Hooker';
  static const String scrumHalf = 'Scrum Half';
  static const String flyHalf = 'Fly Half';
  static const String centre = 'Centre';
  static const String winger = 'Winger';
  static const String locks = 'Locks';
  static const String flankers = 'Flankers';
  static const String numberEight = 'Number Eight';
  static const String fullBack = 'Full Back';

  static const String guard = 'Guard';

  static const List<String> footballPositions = [
    goalkeeper,
    defender,
    midfielder,
    forward,
  ];

  static const List<String> rugby7sPositions = [
    prop,
    hooker,
    scrumHalf,
    flyHalf,
    centre,
    winger,
  ];

  static const List<String> rugby15sPositions = [
    prop,
    hooker,
    locks,
    flankers,
    numberEight,
    scrumHalf,
    flyHalf,
    centre,
    winger,
    fullBack,
  ];

  static const List<String> basketballPositions = [guard, centre, forward];

  static const List<String> hockeyPositions = [
    goalkeeper,
    defender,
    midfielder,
    forward,
  ];

  /// Positions allowed for a match [fixtureType] (e.g. football, rugby15).
  static List<String> forFixtureType(String? fixtureType) {
    switch (fixtureType) {
      case 'football':
      case 'handball':
        return footballPositions;
      case 'rugby7':
        return rugby7sPositions;
      case 'rugby15':
      case 'rugby10':
        return rugby15sPositions;
      case 'basketball':
        return basketballPositions;
      case 'hockey':
        return hockeyPositions;
      default:
        return footballPositions;
    }
  }

  /// Maps a stored/free-text value onto a canonical option, or null if unknown.
  static String? match(String? value, String? fixtureType) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final needle = trimmed.toLowerCase();
    for (final option in forFixtureType(fixtureType)) {
      if (option.toLowerCase() == needle) return option;
    }
    return null;
  }
}
