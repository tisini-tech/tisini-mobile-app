import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class SaveCachedSurveysUsecase implements UseCase<void, SaveCachedSurveysParams> {
  final SurveyRepository repository;

  SaveCachedSurveysUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SaveCachedSurveysParams params) async {
    return repository.saveCachedSurveys(params.surveys);
  }
}

class SaveCachedSurveysParams {
  final List<Survey> surveys;

  const SaveCachedSurveysParams({required this.surveys});
}

class GetCachedSurveysUsecase implements UseCase<List<Survey>, NoParams> {
  final SurveyRepository repository;

  GetCachedSurveysUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Survey>>> call(NoParams params) async {
    return repository.getCachedSurveys();
  }
}

class UpsertCachedSurveyUsecase
    implements UseCase<void, UpsertCachedSurveyParams> {
  final SurveyRepository repository;

  UpsertCachedSurveyUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpsertCachedSurveyParams params) async {
    return repository.upsertCachedSurvey(params.survey);
  }
}

class UpsertCachedSurveyParams {
  final Survey survey;

  const UpsertCachedSurveyParams({required this.survey});
}

class GetCachedSurveyByIdUsecase
    implements UseCase<Survey?, GetCachedSurveyByIdParams> {
  final SurveyRepository repository;

  GetCachedSurveyByIdUsecase({required this.repository});

  @override
  Future<Either<Failure, Survey?>> call(
    GetCachedSurveyByIdParams params,
  ) async {
    return repository.getCachedSurveyById(params.surveyId);
  }
}

class GetCachedSurveyByIdParams {
  final String surveyId;

  const GetCachedSurveyByIdParams({required this.surveyId});
}
