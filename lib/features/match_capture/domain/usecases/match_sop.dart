import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/match_capture/domain/entities/sop.dart';
import 'package:tisini/features/match_capture/domain/repositories/match_capture_repository.dart';

class MatchSopUsecase implements UseCase<Sop, MatchSopParams> {
  final MatchCaptureRepository repository;

  MatchSopUsecase({required this.repository});

  @override
  Future<Either<Failure, Sop>> call(MatchSopParams params) async {
    return await repository.getSop(fixtureId: params.fixtureId);
  }
}

class MatchSopParams {
  final String fixtureId;

  MatchSopParams({required this.fixtureId});
}

class UploadImageUsecase implements UseCase<String, UploadImageParams> {
  final MatchCaptureRepository repository;

  UploadImageUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(UploadImageParams params) async {
    return await repository.uploadImage(path: params.path);
  }
}

class UploadImageParams {
  final String path;

  UploadImageParams({required this.path});
}

class CreateSopUsecase implements UseCase<Sop, CreateSopParams> {
  final MatchCaptureRepository repository;

  CreateSopUsecase({required this.repository});

  @override
  Future<Either<Failure, Sop>> call(CreateSopParams params) async {
    return await repository.createSop(
      fixtureId: params.fixtureId,
      sop: params.sop,
    );
  }
}

class CreateSopParams {
  final String fixtureId;
  final Sop sop;

  CreateSopParams({required this.fixtureId, required this.sop});
}

class UpdateSopUsecase implements UseCase<Sop, UpdateSopParams> {
  final MatchCaptureRepository repository;

  UpdateSopUsecase({required this.repository});

  @override
  Future<Either<Failure, Sop>> call(UpdateSopParams params) async {
    return await repository.updateSop(
      fixtureId: params.fixtureId,
      sopId: params.sopId,
      sop: params.sop,
    );
  }
}

class UpdateSopParams {
  final String fixtureId;
  final String sopId;
  final Sop sop;

  UpdateSopParams({
    required this.fixtureId,
    required this.sopId,
    required this.sop,
  });
}
