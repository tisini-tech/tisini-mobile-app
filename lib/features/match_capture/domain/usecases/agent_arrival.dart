import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/agent_arrival.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class GetAgentArrivalUsecase
    implements UseCase<AgentArrival, GetAgentArrivalParams> {
  GetAgentArrivalUsecase({required this.repository});

  final MatchCaptureRepository repository;

  @override
  Future<Either<Failure, AgentArrival>> call(GetAgentArrivalParams params) {
    return repository.getAgentArrival(fixtureId: params.fixtureId);
  }
}

class GetAgentArrivalParams {
  GetAgentArrivalParams({required this.fixtureId});

  final String fixtureId;
}

class CreateAgentArrivalUsecase
    implements UseCase<AgentArrival, CreateAgentArrivalParams> {
  CreateAgentArrivalUsecase({required this.repository});

  final MatchCaptureRepository repository;

  @override
  Future<Either<Failure, AgentArrival>> call(
    CreateAgentArrivalParams params,
  ) {
    return repository.createAgentArrival(
      fixtureId: params.fixtureId,
      arrival: params.arrival,
    );
  }
}

class CreateAgentArrivalParams {
  CreateAgentArrivalParams({required this.fixtureId, required this.arrival});

  final String fixtureId;
  final AgentArrival arrival;
}
