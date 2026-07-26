import 'package:tisini/shared/fixture_data/domain/entities/sub_event.dart';

class SubEventModel {
  const SubEventModel._();

  static SubEvent fromJson(Map<String, dynamic> json) {
    return SubEvent(
      subEventId: json['subeventid']?.toString() ?? '',
      subEventName: json['subeventname']?.toString() ?? '',
      totalSubEvent: json['totalsubevent']?.toString() ?? '',
      team: json['team']?.toString() ?? '',
      gameId: json['gameidid']?.toString() ?? '',
    );
  }
}
