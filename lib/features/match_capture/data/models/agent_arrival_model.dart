import 'package:tisini/features/match_capture/domain/entities/agent_arrival.dart';

class ArrivalLocationModel extends ArrivalLocation {
  const ArrivalLocationModel({
    required super.lat,
    required super.lon,
    required super.accuracyM,
  });

  factory ArrivalLocationModel.fromEntity(ArrivalLocation location) {
    return ArrivalLocationModel(
      lat: location.lat,
      lon: location.lon,
      accuracyM: location.accuracyM,
    );
  }

  factory ArrivalLocationModel.fromJson(Map<String, dynamic> json) {
    return ArrivalLocationModel(
      lat: _toDouble(json['lat']) ?? 0,
      lon: _toDouble(json['lon']) ?? 0,
      accuracyM: _toDouble(json['accuracy_m']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lon': lon,
    'accuracy_m': accuracyM,
  };

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class AgentArrivalModel extends AgentArrival {
  const AgentArrivalModel({
    super.id,
    super.match,
    super.agent,
    super.status,
    super.arrivalImg,
    super.location,
    super.arrivedAt,
    super.dateUpdated,
  });

  factory AgentArrivalModel.fromEntity(AgentArrival entity) {
    return AgentArrivalModel(
      id: entity.id,
      match: entity.match,
      agent: entity.agent,
      status: entity.status,
      arrivalImg: entity.arrivalImg,
      location: entity.location,
      arrivedAt: entity.arrivedAt,
      dateUpdated: entity.dateUpdated,
    );
  }

  factory AgentArrivalModel.fromJson(Map<String, dynamic> json) {
    final locationJson = json['location'];
    return AgentArrivalModel(
      id: _toInt(json['id']) ?? 0,
      match: _toInt(json['match']) ?? 0,
      agent: _toInt(json['agent']) ?? 0,
      status: json['status']?.toString() ?? '',
      arrivalImg: json['arrival_img']?.toString() ?? '',
      location: locationJson is Map<String, dynamic>
          ? ArrivalLocationModel.fromJson(locationJson)
          : null,
      arrivedAt: DateTime.tryParse(json['arrived_at']?.toString() ?? ''),
      dateUpdated: DateTime.tryParse(json['date_updated']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toCreateJson() {
    final loc = location;
    return {
      'arrival_img': arrivalImg,
      if (loc != null)
        'location': ArrivalLocationModel.fromEntity(loc).toJson(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
