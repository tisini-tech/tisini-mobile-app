import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/event_category.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class GetMatchEventCategoriesUseCase
    implements
        UseCase<List<MatchEventCategory>, GetMatchEventCategoriesParams> {
  final MatchCaptureRepository repository;

  GetMatchEventCategoriesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<MatchEventCategory>>> call(
    GetMatchEventCategoriesParams params,
  ) async {
    return await repository.getMatchEventCategories(
      fixtureType: params.fixtureType,
    );
  }
}

class GetMatchEventCategoriesParams {
  final String fixtureType;

  GetMatchEventCategoriesParams({required this.fixtureType});
}
