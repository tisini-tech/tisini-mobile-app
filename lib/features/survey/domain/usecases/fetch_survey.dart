import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class FetchSurveyUsecase implements UseCase<List<Survey>, NoParams> {
  final SurveyRepository repository;

  FetchSurveyUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Survey>>> call(NoParams params) async {
    return await repository.getSurvey();
  }
}

class FetchSurveyQuestionsUsecase implements UseCase<Survey, SurveyParams> {
  final SurveyRepository repository;

  FetchSurveyQuestionsUsecase({required this.repository});

  @override
  Future<Either<Failure, Survey>> call(SurveyParams params) async {
    return await repository.getSurveyQuestions(params.surveyId);
  }
}

class SurveyParams {
  final String surveyId;

  SurveyParams({required this.surveyId});
}
