import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class SaveMatchEventLocally
    implements UseCase<Map<String, dynamic>, SaveMatchEventLocallyParams> {
  final MatchCaptureRepository repository;

  SaveMatchEventLocally({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    SaveMatchEventLocallyParams params,
  ) async {
    return repository.saveMatchEventLocally(
      fixtureId: params.fixtureId,
      event: params.event,
    );
  }
}

class SaveMatchEventLocallyParams {
  final String fixtureId;
  final Map<String, dynamic> event;

  const SaveMatchEventLocallyParams({
    required this.fixtureId,
    required this.event,
  });
}
