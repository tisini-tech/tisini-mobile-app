import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class SyncEventsUsecase implements UseCase<String, SyncEventsParams> {
  final MatchCaptureRepository repository;

  SyncEventsUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(SyncEventsParams params) async {
    return repository.syncPendingMatchEvents(fixtureId: params.fixtureId);
  }
}

class SyncEventsParams {
  final String fixtureId;

  const SyncEventsParams({required this.fixtureId});
}
