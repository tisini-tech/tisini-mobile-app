import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class StartMatchUsecase implements UseCase<String, StartMatchParams> {
  final MatchCaptureRepository repository;

  StartMatchUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(StartMatchParams params) async {
    return await repository.startMatch(
      token: params.token,
      fixtureId: params.fixtureId,
    );
  }
}

class StartMatchParams {
  final String token;
  final String fixtureId;

  StartMatchParams({required this.token, required this.fixtureId});
}

class EndHalfUsecase implements UseCase<String, EndHalfParams> {
  final MatchCaptureRepository repository;

  EndHalfUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(EndHalfParams params) async {
    return await repository.endHalf(
      token: params.token,
      fixtureId: params.fixtureId,
      minute: params.minute,
      second: params.second,
      status: params.status,
      moment: params.moment,
    );
  }
}

class EndHalfParams {
  final String token;
  final String fixtureId;
  final String minute;
  final String second;
  final String status;
  final String moment;

  EndHalfParams({
    required this.token,
    required this.fixtureId,
    required this.minute,
    required this.second,
    required this.status,
    required this.moment,
  });
}
