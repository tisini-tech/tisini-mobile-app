import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

/// Saves the list of submitted match events for a fixture to local storage.
class SaveSubmittedEventsUsecase {
  final MatchCaptureRepository repository;

  SaveSubmittedEventsUsecase({required this.repository});

  Future<void> call(String fixtureId, List<Map<String, dynamic>> events) =>
      repository.saveSubmittedEvents(fixtureId, events);
}
