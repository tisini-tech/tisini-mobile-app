import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/survey/data/datasources/survey_local_data_source.dart';
import 'package:tisini/features/survey/data/datasources/survey_remote_source.dart';
import 'package:tisini/features/survey/data/models/pending_survey_submission_model.dart';
import 'package:tisini/features/survey/data/models/survey_model.dart';
import 'package:tisini/features/survey/domain/entities/engagement_response_stats.dart';
import 'package:tisini/features/survey/domain/entities/pending_survey_submission.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  static const _engagementMetadataKeys = {
    'referral_code',
    'survey_id',
    'saved_at',
    'local_id',
    'status',
    'uploaded',
    'uploaded_at',
  };

  final SurveyLocalDataSource localDataSource;
  final SurveyRemoteSource remoteDataSource;

  SurveyRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> saveSubmission(
    PendingSurveySubmission submission,
  ) async {
    try {
      final model = submission is PendingSurveySubmissionModel
          ? submission
          : PendingSurveySubmissionModel.fromEntity(submission);
      await localDataSource.saveSubmission(model);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PendingSurveySubmission>>>
  getPendingSubmissions() async {
    try {
      final list = await localDataSource.getPendingSubmissions();
      return Right(list);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalSubmissionCount() async {
    try {
      final count = await localDataSource.getTotalSubmissionCount();
      return Right(count);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getLastReferralCode() async {
    try {
      final code = await localDataSource.getLastReferralCode();
      return Right(code);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLastReferralCode(String code) async {
    try {
      await localDataSource.saveLastReferralCode(code);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPendingSurveys(
    List<Map<String, dynamic>> payloads,
  ) async {
    try {
      final result = await remoteDataSource.uploadPendingSurveys(payloads);
      if (result.surveyIds.isNotEmpty) {
        await localDataSource.markAsSynced(result.surveyIds);
      }
      return Right(result.message);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Survey>>> getSurvey() async {
    try {
      final list = await remoteDataSource.getSurvey();
      return Right(list);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveCachedSurveys(List<Survey> surveys) async {
    try {
      final models = surveys
          .map((s) => s is SurveyModel ? s : SurveyModel.fromEntity(s))
          .toList();
      await localDataSource.saveCachedSurveys(models);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Survey>>> getCachedSurveys() async {
    try {
      final list = await localDataSource.getCachedSurveys();
      return Right(list);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveSurvey(
    Map<String, dynamic> survey,
    String code,
    String surveyId,
    String localId,
    String savedAt,
  ) async {
    try {
      final result = await remoteDataSource.saveSurvey(
        survey,
        code,
        surveyId,
        localId,
        savedAt,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> saveEngagementResponseLocally(
    Map<String, dynamic> response,
  ) async {
    try {
      final saved = await localDataSource.saveEngagementResponse(response);

      return Right(saved);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getEngagementResponseCount() async {
    try {
      final count = await localDataSource.getEngagementResponseCount();
      return Right(count);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateEngagementResponseStatus({
    required String localId,
    required String status,
  }) async {
    try {
      final updated = await localDataSource.updateEngagementResponseStatus(
        localId: localId,
        status: status,
      );
      return Right(updated);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EngagementResponseStats>>
  getEngagementResponseStats() async {
    try {
      final stats = await localDataSource.getEngagementResponseStats();
      return Right(stats);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> syncPendingEngagementResponses() async {
    try {
      final pending =
          await localDataSource.getEngagementResponsesPendingSync();
      if (pending.isEmpty) {
        return const Right('No responses to sync');
      }

      var synced = 0;
      for (final record in pending) {
        final localId = record['local_id']?.toString() ?? '';
        if (localId.isEmpty) continue;

        final survey = _extractSurveyAnswers(record);
        final surveyId = record['survey_id']?.toString() ?? '';
        final referral = record['referral_code']?.toString() ?? '';
        final savedAt = record['saved_at']?.toString() ?? '';

        await remoteDataSource.saveSurvey(
          survey,
          referral,
          surveyId,
          localId,
          savedAt,
        );
        await localDataSource.updateEngagementResponseStatus(
          localId: localId,
          status: 'success',
        );
        synced++;
      }

      if (synced == 0) {
        return Left(Failure('Could not sync any responses'));
      }
      return Right('Synced $synced of ${pending.length} response(s)');
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  static Map<String, dynamic> _extractSurveyAnswers(
    Map<String, dynamic> record,
  ) {
    return {
      for (final entry in record.entries)
        if (!_engagementMetadataKeys.contains(entry.key))
          entry.key: entry.value,
    };
  }
}
