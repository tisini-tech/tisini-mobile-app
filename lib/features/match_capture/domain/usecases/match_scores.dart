import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/match_score.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class MatchScoresUsecase implements UseCase<MatchScore, MatchScoresParams> {
  final MatchCaptureRepository repository;

  MatchScoresUsecase({required this.repository});

  @override
  Future<Either<Failure, MatchScore>> call(MatchScoresParams params) async {
    return await repository.getMatchScore(fixtureId: params.fixtureId);
  }
}

class MatchScoresParams {
  final String fixtureId;

  MatchScoresParams({required this.fixtureId});
}
