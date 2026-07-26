import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/match_event.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class MatchEventsUsecase
    implements UseCase<List<MatchEvent>, MatchEventsParams> {
  final MatchCaptureRepository repository;

  MatchEventsUsecase({required this.repository});

  @override
  Future<Either<Failure, List<MatchEvent>>> call(
    MatchEventsParams params,
  ) async {
    return await repository.getMatchEvents(
      fixtureId: params.fixtureId,
      isCritical: params.isCritical,
      isLastTen: params.isLastTen,
    );
  }
}

class MatchEventsParams {
  final String fixtureId;
  final bool isCritical;
  final bool isLastTen;

  MatchEventsParams({
    required this.fixtureId,
    this.isCritical = false,
    this.isLastTen = false,
  });
}

class CreateMatchEventUsecase
    implements UseCase<String, CreateMatchEventParams> {
  final MatchCaptureRepository repository;

  CreateMatchEventUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(CreateMatchEventParams params) async {
    return await repository.createMatchEvent(
      fixtureId: params.fixtureId,
      addOwnGoal: params.addOwnGoal,
      matchEvent: params.matchEvent,
    );
  }
}

class CreateMatchEventParams {
  final String fixtureId;
  final Map<String, dynamic> matchEvent;
  final bool addOwnGoal;

  CreateMatchEventParams({
    required this.fixtureId,
    required this.matchEvent,
    required this.addOwnGoal,
  });
}

class UpdateMatchEventUsecase
    implements UseCase<MatchEvent, UpdateMatchEventParams> {
  final MatchCaptureRepository repository;

  UpdateMatchEventUsecase({required this.repository});

  @override
  Future<Either<Failure, MatchEvent>> call(
    UpdateMatchEventParams params,
  ) async {
    return await repository.updateMatchEvent(
      fixtureId: params.fixtureId,
      eventId: params.eventId,
      matchEvent: params.matchEvent,
    );
  }
}

class UpdateMatchEventParams {
  final String fixtureId;
  final String eventId;
  final Map<String, dynamic> matchEvent;

  UpdateMatchEventParams({
    required this.fixtureId,
    required this.eventId,
    required this.matchEvent,
  });
}

class DeleteMatchEventUsecase
    implements UseCase<String, DeleteMatchEventParams> {
  final MatchCaptureRepository repository;

  DeleteMatchEventUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(DeleteMatchEventParams params) async {
    return await repository.deleteMatchEvent(
      fixtureId: params.fixtureId,
      eventId: params.eventId,
    );
  }
}

class DeleteMatchEventParams {
  final String fixtureId;
  final String eventId;

  DeleteMatchEventParams({required this.fixtureId, required this.eventId});
}
