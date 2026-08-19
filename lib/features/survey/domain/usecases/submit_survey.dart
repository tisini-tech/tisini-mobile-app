import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class SubmitSurveyUsecase implements UseCase<String, SubmitSurveyParams> {
  final SurveyRepository repository;

  SubmitSurveyUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(SubmitSurveyParams params) async {
    return repository.saveSurvey(params.survey, params.surveyId);
  }
}

class SubmitSurveyParams {
  final List<Map<String, dynamic>> survey;
  final String surveyId;

  SubmitSurveyParams({required this.survey, required this.surveyId});
}
