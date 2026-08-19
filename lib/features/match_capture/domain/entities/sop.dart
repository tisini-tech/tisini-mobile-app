class SopWeather {
  SopWeather._();

  static const sunny = 'sunny';
  static const cloudy = 'cloudy';
  static const overcast = 'overcast';
  static const lightRain = 'light_rain';
  static const heavyRain = 'heavy_rain';
  static const windy = 'windy';
  static const fog = 'fog';

  static const values = [
    sunny,
    cloudy,
    overcast,
    lightRain,
    heavyRain,
    windy,
    fog,
  ];

  static const labels = {
    sunny: 'Sunny',
    cloudy: 'Cloudy',
    overcast: 'Overcast',
    lightRain: 'Light rain',
    heavyRain: 'Heavy rain',
    windy: 'Windy',
    fog: 'Fog',
  };

  static String labelOf(String value) => labels[value] ?? value;
}

class Sop {
  const Sop({
    this.id = 0,
    this.match = 0,
    this.sop = const [],
    this.homeLineupImg = '',
    this.awayLineupImg = '',
    this.refDataImg = '',
    this.refDataJson = const {},
    this.homeLineupAt,
    this.awayLineupAt,
    this.refDataAt,
    this.corrections = const [],
    this.weather = '',
    this.createdBy = 0,
    this.dateCreated,
    this.dateUpdated,
  });

  final int id;
  final int match;
  final List<String> sop;
  final String homeLineupImg;
  final String awayLineupImg;
  final String refDataImg;
  final Map<String, dynamic> refDataJson;
  final DateTime? homeLineupAt;
  final DateTime? awayLineupAt;
  final DateTime? refDataAt;
  final List<String> corrections;
  final String weather;
  final int createdBy;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;

  bool get hasContent =>
      id > 0 ||
      sop.isNotEmpty ||
      corrections.isNotEmpty ||
      homeLineupImg.isNotEmpty ||
      awayLineupImg.isNotEmpty ||
      refDataImg.isNotEmpty ||
      refDataJson.isNotEmpty ||
      weather.trim().isNotEmpty;
}
