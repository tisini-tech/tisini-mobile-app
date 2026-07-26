import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class MatchMetricsUsecase implements UseCase<List<Metric>, MatchMetricsParams> {
  final MatchCaptureRepository repository;

  MatchMetricsUsecase({required this.repository});

  @override
  Future<Either<Failure, List<Metric>>> call(MatchMetricsParams params) async {
    return await repository.getMatchMetrics(fixtureType: params.fixtureType);
  }
}

class MatchMetricsParams {
  final String fixtureType;

  MatchMetricsParams({required this.fixtureType});
}
