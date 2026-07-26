/// Helpers for local match-event upload/sync state.
abstract final class MatchEventSync {
  MatchEventSync._();

  /// Keys stored locally but not sent to POST /fixtures/{id}/match-events.
  static const eventMetadataKeys = {
    'local_id',
    'saved_at',
    'status',
    'uploaded',
    'uploaded_at',
    'add_own_goal',
  };

  /// Exact body shape expected by the match-events API.
  static const apiFieldKeys = [
    'metric_id',
    'metric_detail_id',
    'metric_sub_detail_id',
    'player_id',
    'subplayer_id',
    'team_id',
    'minute',
    'second',
    'moment',
    'quarter',
    'narration',
    'localid',
    'app_timelog',
    'sync_status',
  ];

  static String resolveLocalId(Map<String, dynamic> event) {
    return event['local_id']?.toString() ?? event['localid']?.toString() ?? '';
  }

  static bool isSynced(Map<String, dynamic> event) {
    final status = event['status']?.toString();
    if (status == 'success') return true;
    if (status == 'failed' || status == 'pending') return false;
    return event['uploaded'] == true;
  }

  static bool isPendingSync(Map<String, dynamic> event) => !isSynced(event);

  static bool isOwnGoal(Map<String, dynamic> event) {
    final value = event['add_own_goal'];
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  /// Builds the API payload from metric fields + match context.
  static Map<String, dynamic> buildPayload({
    required int metricId,
    int metricDetailId = 0,
    int metricSubDetailId = 0,
    int playerId = 0,
    int subplayerId = 0,
    required int teamId,
    required int minute,
    required int second,
    required String moment,
    required String quarter,
    String narration = '',
    required String localId,
    required String appTimelog,
    int syncStatus = 0,
  }) {
    return {
      'metric_id': metricId,
      'metric_detail_id': metricDetailId,
      'metric_sub_detail_id': metricSubDetailId,
      'player_id': playerId,
      'subplayer_id': subplayerId,
      'team_id': teamId,
      'minute': minute,
      'second': second,
      'moment': moment,
      'quarter': quarter,
      'narration': narration,
      'localid': localId,
      'app_timelog': appTimelog,
      'sync_status': syncStatus,
    };
  }

  /// Normalizes a stored record into the exact API body shape.
  static Map<String, dynamic> payloadForUpload(
    Map<String, dynamic> record, {
    int syncStatus = 0,
  }) {
    final source = <String, dynamic>{
      for (final entry in record.entries)
        if (!eventMetadataKeys.contains(entry.key) && entry.key != 'local_id')
          entry.key: entry.value,
    };

    // Legacy typo from older clients.
    if (source.containsKey('playerid') && !source.containsKey('player_id')) {
      source['player_id'] = source.remove('playerid');
    }

    return buildPayload(
      metricId: _asInt(source['metric_id']),
      metricDetailId: _asInt(source['metric_detail_id']),
      metricSubDetailId: _asInt(source['metric_sub_detail_id']),
      playerId: _asInt(source['player_id']),
      subplayerId: _asInt(source['subplayer_id']),
      teamId: _asInt(source['team_id']),
      minute: _asInt(source['minute']),
      second: _asInt(source['second']),
      moment: source['moment']?.toString() ?? '',
      quarter: source['quarter']?.toString() ?? '',
      narration: source['narration']?.toString() ?? '',
      localId:
          source['localid']?.toString() ??
          record['local_id']?.toString() ??
          '',
      appTimelog:
          source['app_timelog']?.toString() ??
          DateTime.now().toUtc().toIso8601String(),
      syncStatus: syncStatus,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
