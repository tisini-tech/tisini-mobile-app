import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class GetEngagementResponseCount implements UseCase<int, NoParams> {
  final SurveyRepository repository;

  GetEngagementResponseCount({required this.repository});

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.getEngagementResponseCount();
  }
}
