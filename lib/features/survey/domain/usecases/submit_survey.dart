import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class SubmitSurveyUsecase implements UseCase<String, SubmitSurveyParams> {
  final SurveyRepository repository;

  SubmitSurveyUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(SubmitSurveyParams params) async {
    return repository.saveSurvey(
      params.survey,
      params.code,
      params.surveyId,
      params.localId,
      params.savedAt,
    );
  }
}

class SubmitSurveyParams {
  final Map<String, dynamic> survey;
  final String code;
  final String surveyId;
  final String localId;
  final String savedAt;

  SubmitSurveyParams({
    required this.survey,
    required this.code,
    required this.surveyId,
    required this.localId,
    required this.savedAt,
  });
}
