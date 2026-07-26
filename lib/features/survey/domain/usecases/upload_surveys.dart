import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class UploadSurveysUsecase implements UseCase<String, UploadSurveysParams> {
  final SurveyRepository repository;

  UploadSurveysUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(UploadSurveysParams params) async {
    return await repository.uploadPendingSurveys(params.payloads);
  }
}

class UploadSurveysParams {
  final List<Map<String, dynamic>> payloads;

  UploadSurveysParams({required this.payloads});
}
