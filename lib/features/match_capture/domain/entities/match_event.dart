class MatchEvent {
  final SingleIdName metric;
  final SingleIdName? metricDetail;
  final SingleIdName? metricSubDetail;
  final SingleIdName? player;
  final SingleIdName? subplayer;
  final SingleIdName? agent;
  final int id;
  final int match;
  final int team;
  final int minute;
  final int second;
  final String moment;
  final String quarter;
  final String narration;
  final int zoneId;
  final double? xper;
  final double? yper;
  final int videoTimestamp;
  final int? noRuck;
  final int? noLineout;
  final double? meterGain;
  final String? kickfrom;
  final String? kickland;
  final String? defender;
  final double? strength;
  final String localid;
  final String appTimelog;
  final int syncStatus;

  MatchEvent({
    required this.metric,
    required this.metricDetail,
    required this.metricSubDetail,
    required this.player,
    required this.subplayer,
    required this.agent,
    required this.id,
    required this.match,
    required this.team,
    required this.minute,
    required this.second,
    required this.moment,
    required this.quarter,
    required this.narration,
    required this.zoneId,
    required this.xper,
    required this.yper,
    required this.videoTimestamp,
    required this.noRuck,
    required this.noLineout,
    required this.meterGain,
    required this.kickfrom,
    required this.kickland,
    required this.defender,
    required this.strength,
    required this.localid,
    required this.appTimelog,
    required this.syncStatus,
  });
}

class SingleIdName {
  final int id;
  final String name;

  const SingleIdName({required this.id, required this.name});
}
