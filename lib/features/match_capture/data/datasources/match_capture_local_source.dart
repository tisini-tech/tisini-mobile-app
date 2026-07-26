import 'package:get_storage/get_storage.dart';

/// Persists submitted match events per fixture (e.g. for offline/recovery).
abstract interface class MatchCaptureLocalSource {
  /// Saves the list of submitted events for the given [fixtureId].
  Future<void> saveSubmittedEvents(
    String fixtureId,
    List<Map<String, dynamic>> events,
  );

  /// Returns the list of submitted events for [fixtureId], or empty if none.
  Future<List<Map<String, dynamic>>> getSubmittedEvents(String fixtureId);

  /// Appends one match event (payload + metadata) for local history/retry.
  /// Returns the record that was written to storage.
  Future<Map<String, dynamic>> saveMatchEventLocally(
    String fixtureId,
    Map<String, dynamic> event,
  );

  /// Updates [status] / [uploaded] for the record matching [localId].
  Future<Map<String, dynamic>> updateMatchEventStatus({
    required String fixtureId,
    required String localId,
    required String status,
  });
}

class MatchCaptureLocalSourceImpl implements MatchCaptureLocalSource {
  MatchCaptureLocalSourceImpl({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  static String _key(String fixtureId) => 'match_capture_submitted_$fixtureId';

  @override
  Future<void> saveSubmittedEvents(
    String fixtureId,
    List<Map<String, dynamic>> events,
  ) async {
    if (fixtureId.isEmpty) return;
    await _box.write(_key(fixtureId), events);
  }

  @override
  Future<List<Map<String, dynamic>>> getSubmittedEvents(
    String fixtureId,
  ) async {
    if (fixtureId.isEmpty) return [];
    final stored = _box.read(_key(fixtureId));
    if (stored is! List) return [];
    return stored
        .map(
          (e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{},
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> saveMatchEventLocally(
    String fixtureId,
    Map<String, dynamic> event,
  ) async {
    if (fixtureId.isEmpty) {
      throw ArgumentError.value(fixtureId, 'fixtureId', 'cannot be empty');
    }

    final saved = Map<String, dynamic>.from(event);
    saved.putIfAbsent(
      'saved_at',
      () => DateTime.now().toIso8601String(),
    );
    saved.putIfAbsent('status', () => 'pending');
    saved.putIfAbsent('uploaded', () => false);

    final list = await getSubmittedEvents(fixtureId);
    list.add(saved);
    await _box.write(_key(fixtureId), list);
    return saved;
  }

  @override
  Future<Map<String, dynamic>> updateMatchEventStatus({
    required String fixtureId,
    required String localId,
    required String status,
  }) async {
    final list = await getSubmittedEvents(fixtureId);
    final index = list.indexWhere(
      (event) =>
          event['local_id']?.toString() == localId ||
          event['localid']?.toString() == localId,
    );
    if (index < 0) {
      throw StateError('Match event not found: $localId');
    }

    final updated = <String, dynamic>{
      ...list[index],
      'status': status,
      'uploaded': status == 'success',
    };
    if (status == 'success') {
      updated['uploaded_at'] = DateTime.now().toIso8601String();
    }

    list[index] = updated;
    await _box.write(_key(fixtureId), list);
    return updated;
  }
}
