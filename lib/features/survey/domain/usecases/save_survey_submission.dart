import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/entities/pending_survey_submission.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class SaveSurveySubmission implements UseCase<void, SaveSurveySubmissionParams> {
  final SurveyRepository repository;

  SaveSurveySubmission({required this.repository});

  @override
  Future<Either<Failure, void>> call(SaveSurveySubmissionParams params) async {
    return await repository.saveSubmission(params.submission);
  }
}

class SaveSurveySubmissionParams {
  final PendingSurveySubmission submission;

  const SaveSurveySubmissionParams({required this.submission});
}
