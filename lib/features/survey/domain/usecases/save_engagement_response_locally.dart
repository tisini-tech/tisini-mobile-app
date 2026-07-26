import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class SaveEngagementResponseLocally
    implements UseCase<Map<String, dynamic>, SaveEngagementResponseLocallyParams> {
  final SurveyRepository repository;

  SaveEngagementResponseLocally({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    SaveEngagementResponseLocallyParams params,
  ) async {
    return await repository.saveEngagementResponseLocally(params.response);
  }
}

class SaveEngagementResponseLocallyParams {
  final Map<String, dynamic> response;

  const SaveEngagementResponseLocallyParams({required this.response});
}
