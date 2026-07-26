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
