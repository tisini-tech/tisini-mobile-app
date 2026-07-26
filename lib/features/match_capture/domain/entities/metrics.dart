class Metric {
  final List<Detail> details;
  final List<SubDetail> subDetails;
  final int id;
  final String name;
  final int fixtureType;
  final int isPlayer;
  final int isTimeline;
  final int isTeam;
  final int isActive;
  final int gke;
  final int closewindow;
  final int uploaddata;
  final int? ref;
  final int order;
  final int metricCategory;
  final double? strength;

  Metric({
    required this.details,
    required this.subDetails,
    required this.id,
    required this.name,
    required this.fixtureType,
    required this.isPlayer,
    required this.isTimeline,
    required this.isTeam,
    required this.isActive,
    required this.gke,
    required this.closewindow,
    required this.uploaddata,
    required this.ref,
    required this.order,
    required this.metricCategory,
    required this.strength,
  });
}

class Detail {
  final String id;
  final String name;
  final String metric;
  final bool isPlayer;
  final String position;
  final double? strength;

  Detail({
    required this.id,
    required this.name,
    required this.metric,
    required this.strength,
    required this.isPlayer,
    required this.position,
  });
}

class SubDetail {
  final String id;
  final String name;
  final bool isPlayer;
  final String position;
  final double? strength;

  SubDetail({
    required this.id,
    required this.name,
    required this.strength,
    required this.isPlayer,
    required this.position,
  });
}
