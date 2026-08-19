class ArrivalLocation {
  const ArrivalLocation({
    required this.lat,
    required this.lon,
    required this.accuracyM,
  });

  final double lat;
  final double lon;
  final double accuracyM;
}

class AgentArrival {
  const AgentArrival({
    this.id = 0,
    this.match = 0,
    this.agent = 0,
    this.status = '',
    this.arrivalImg = '',
    this.location,
    this.arrivedAt,
    this.dateUpdated,
  });

  final int id;
  final int match;
  final int agent;
  final String status;
  final String arrivalImg;
  final ArrivalLocation? location;
  final DateTime? arrivedAt;
  final DateTime? dateUpdated;

  bool get hasArrived => id > 0 || arrivalImg.trim().isNotEmpty;
}
