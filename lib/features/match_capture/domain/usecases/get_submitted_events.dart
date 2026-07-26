import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

/// Returns the list of submitted match events for a fixture from local storage.
class GetSubmittedEventsUsecase {
  final MatchCaptureRepository repository;

  GetSubmittedEventsUsecase({required this.repository});

  Future<List<Map<String, dynamic>>> call(String fixtureId) =>
      repository.getSubmittedEvents(fixtureId);
}
