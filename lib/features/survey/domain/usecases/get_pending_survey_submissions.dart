import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/entities/pending_survey_submission.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class GetPendingSurveySubmissions
    implements UseCase<List<PendingSurveySubmission>, NoParams> {
  final SurveyRepository repository;

  GetPendingSurveySubmissions({required this.repository});

  @override
  Future<Either<Failure, List<PendingSurveySubmission>>> call(
    NoParams params,
  ) async {
    return await repository.getPendingSubmissions();
  }
}
