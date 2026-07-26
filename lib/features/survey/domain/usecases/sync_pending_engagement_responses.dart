import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class SyncPendingEngagementResponses implements UseCase<String, NoParams> {
  final SurveyRepository repository;

  SyncPendingEngagementResponses({required this.repository});

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return repository.syncPendingEngagementResponses();
  }
}
