import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class UpdateMatchEventStatus
    implements UseCase<Map<String, dynamic>, UpdateMatchEventStatusParams> {
  final MatchCaptureRepository repository;

  UpdateMatchEventStatus({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    UpdateMatchEventStatusParams params,
  ) async {
    return repository.updateMatchEventStatus(
      fixtureId: params.fixtureId,
      localId: params.localId,
      status: params.status,
    );
  }
}

class UpdateMatchEventStatusParams {
  final String fixtureId;
  final String localId;
  final String status;

  const UpdateMatchEventStatusParams({
    required this.fixtureId,
    required this.localId,
    required this.status,
  });
}
