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
