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
    'sync_status',
    'answers',
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
  Future<Either<Failure, Survey>> getSurveyQuestions(String surveyId) async {
    try {
      final survey = await remoteDataSource.getSurveyQuestions(surveyId);
      return Right(survey);
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
  Future<Either<Failure, void>> upsertCachedSurvey(Survey survey) async {
    try {
      final model = survey is SurveyModel
          ? survey
          : SurveyModel.fromEntity(survey);
      await localDataSource.upsertCachedSurvey(model);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Survey?>> getCachedSurveyById(String surveyId) async {
    try {
      final survey = await localDataSource.getCachedSurveyById(surveyId);
      return Right(survey);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveSurvey(
    List<Map<String, dynamic>> survey,
    String surveyId,
  ) async {
    try {
      final result = await remoteDataSource.saveSurvey(survey, surveyId);

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
      final pending = await localDataSource.getEngagementResponsesPendingSync();
      if (pending.isEmpty) {
        return const Right('No responses to sync');
      }

      var synced = 0;
      for (final record in pending) {
        final localId = record['local_id']?.toString() ?? '';
        if (localId.isEmpty) continue;

        final surveyId = record['survey_id']?.toString() ?? '';
        if (surveyId.isEmpty) continue;

        final answers = _extractSurveyAnswers(record);
        if (answers.isEmpty) continue;

        try {
          await remoteDataSource.saveSurvey(answers, surveyId);
          await localDataSource.updateEngagementResponseStatus(
            localId: localId,
            status: 'success',
          );
          synced++;
        } catch (_) {
          await localDataSource.updateEngagementResponseStatus(
            localId: localId,
            status: 'failed',
          );
        }
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

  static List<Map<String, dynamic>> _extractSurveyAnswers(
    Map<String, dynamic> record,
  ) {
    final answers = record['answers'];
    if (answers is List) {
      return [
        for (final item in answers)
          if (item is Map) Map<String, dynamic>.from(item),
      ];
    }

    // Legacy flat map stored as a single list item.
    return [
      {
        for (final entry in record.entries)
          if (!_engagementMetadataKeys.contains(entry.key))
            entry.key: entry.value,
      },
    ];
  }
}
