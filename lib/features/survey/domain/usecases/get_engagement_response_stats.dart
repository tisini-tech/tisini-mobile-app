import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/entities/engagement_response_stats.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class GetEngagementResponseStats
    implements UseCase<EngagementResponseStats, NoParams> {
  final SurveyRepository repository;

  GetEngagementResponseStats({required this.repository});

  @override
  Future<Either<Failure, EngagementResponseStats>> call(NoParams params) async {
    return repository.getEngagementResponseStats();
  }
}
