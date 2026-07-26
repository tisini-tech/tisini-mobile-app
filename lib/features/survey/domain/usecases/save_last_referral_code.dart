import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class SaveLastReferralCode implements UseCase<void, SaveLastReferralCodeParams> {
  final SurveyRepository repository;

  SaveLastReferralCode({required this.repository});

  @override
  Future<Either<Failure, void>> call(SaveLastReferralCodeParams params) async {
    return await repository.saveLastReferralCode(params.code);
  }
}

class SaveLastReferralCodeParams {
  final String code;

  const SaveLastReferralCodeParams({required this.code});
}
