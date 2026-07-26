import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class UpdateEngagementResponseStatus
    implements UseCase<Map<String, dynamic>, UpdateEngagementResponseStatusParams> {
  final SurveyRepository repository;

  UpdateEngagementResponseStatus({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    UpdateEngagementResponseStatusParams params,
  ) async {
    return repository.updateEngagementResponseStatus(
      localId: params.localId,
      status: params.status,
    );
  }
}

class UpdateEngagementResponseStatusParams {
  final String localId;
  final String status;

  const UpdateEngagementResponseStatusParams({
    required this.localId,
    required this.status,
  });
}
