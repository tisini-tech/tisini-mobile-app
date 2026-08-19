import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/survey/domain/entities/engagement_response_stats.dart';
import 'package:tisini/features/survey/domain/entities/pending_survey_submission.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';

abstract interface class SurveyRepository {
  /// Saves a survey submission to local storage (pending upload).
  Future<Either<Failure, void>> saveSubmission(
    PendingSurveySubmission submission,
  );

  /// Returns all pending submissions that have not been synced.
  Future<Either<Failure, List<PendingSurveySubmission>>>
  getPendingSubmissions();

  /// Total number of submissions (synced + pending).
  Future<Either<Failure, int>> getTotalSubmissionCount();

  /// Last referral code entered by the user (for pre-fill).
  Future<Either<Failure, String?>> getLastReferralCode();

  /// Persist referral code so it can be pre-filled next time.
  Future<Either<Failure, void>> saveLastReferralCode(String code);

  Future<Either<Failure, List<Survey>>> getSurvey();

  Future<Either<Failure, Survey>> getSurveyQuestions(String surveyId);

  Future<Either<Failure, void>> saveCachedSurveys(List<Survey> surveys);

  Future<Either<Failure, List<Survey>>> getCachedSurveys();

  /// Merge a survey (typically with questions) into the local cache.
  Future<Either<Failure, void>> upsertCachedSurvey(Survey survey);

  Future<Either<Failure, Survey?>> getCachedSurveyById(String surveyId);

  Future<Either<Failure, String>> saveSurvey(
    List<Map<String, dynamic>> survey,
    String surveyId,
  );

  /// Save engagement response locally (for count/history).
  /// Returns the persisted record (including metadata such as [saved_at]).
  Future<Either<Failure, Map<String, dynamic>>> saveEngagementResponseLocally(
    Map<String, dynamic> response,
  );

  /// Number of engagement responses saved locally.
  Future<Either<Failure, int>> getEngagementResponseCount();

  Future<Either<Failure, EngagementResponseStats>> getEngagementResponseStats();

  /// Uploads locally stored responses that are not [status] success.
  Future<Either<Failure, String>> syncPendingEngagementResponses();

  /// Persists upload outcome for an engagement response ([status]: pending | success | failed).
  Future<Either<Failure, Map<String, dynamic>>> updateEngagementResponseStatus({
    required String localId,
    required String status,
  });
}
