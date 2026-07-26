import 'package:get_storage/get_storage.dart';
import 'package:tisini/features/survey/data/models/pending_survey_submission_model.dart';
import 'package:tisini/features/survey/data/models/survey_model.dart';
import 'package:tisini/features/survey/domain/entities/engagement_response_stats.dart';

abstract interface class SurveyLocalDataSource {
  Future<void> saveSubmission(PendingSurveySubmissionModel submission);
  Future<List<PendingSurveySubmissionModel>> getPendingSubmissions();
  Future<int> getTotalSubmissionCount();
  Future<String?> getLastReferralCode();
  Future<void> saveLastReferralCode(String code);
  /// Mark submissions as synced by their IDs (after successful server upload).
  Future<void> markAsSynced(List<String> surveyIds);

  /// Append one engagement response (payload + metadata) for local history/count.
  /// Returns the record that was written to storage.
  Future<Map<String, dynamic>> saveEngagementResponse(
    Map<String, dynamic> response,
  );
  /// Number of saved engagement responses.
  Future<int> getEngagementResponseCount();

  Future<EngagementResponseStats> getEngagementResponseStats();

  /// Responses not yet uploaded successfully ([status] != success).
  Future<List<Map<String, dynamic>>> getEngagementResponsesPendingSync();

  /// Updates [status] / [uploaded] for the record matching [localId].
  Future<Map<String, dynamic>> updateEngagementResponseStatus({
    required String localId,
    required String status,
  });

  /// Cached engagement survey definitions (offline fallback).
  Future<void> saveCachedSurveys(List<SurveyModel> surveys);

  Future<List<SurveyModel>> getCachedSurveys();
}

const String _surveyBoxKey = 'survey_pending_submissions';
const String _lastReferralCodeKey = 'survey_last_referral_code';
const String _engagementResponsesKey = 'engagement_responses';
const String _cachedEngagementSurveysKey = 'cached_engagement_surveys';

class SurveyLocalDataSourceImpl implements SurveyLocalDataSource {
  final GetStorage _box;

  SurveyLocalDataSourceImpl({GetStorage? box}) : _box = box ?? GetStorage();

  Future<List<PendingSurveySubmissionModel>> _getAllSubmissions() async {
    final raw = _box.read(_surveyBoxKey);
    if (raw == null) return [];
    final list = raw as List<dynamic>;
    return list
        .map((e) =>
            PendingSurveySubmissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveSubmission(PendingSurveySubmissionModel submission) async {
    final list = await _getAllSubmissions();
    list.add(submission);
    await _box.write(
      _surveyBoxKey,
      list.map((e) => e.toJson()).toList(),
    );
  }

  /// Returns only submissions with synced == false (so we only send unsynced to server).
  @override
  Future<List<PendingSurveySubmissionModel>> getPendingSubmissions() async {
    final all = await _getAllSubmissions();
    return all.where((s) => !s.synced).toList();
  }

  @override
  Future<int> getTotalSubmissionCount() async {
    final all = await _getAllSubmissions();
    return all.length;
  }

  @override
  Future<String?> getLastReferralCode() async {
    final v = _box.read(_lastReferralCodeKey);
    return v is String ? v : null;
  }

  @override
  Future<void> saveLastReferralCode(String code) async {
    await _box.write(_lastReferralCodeKey, code.trim());
  }

  @override
  Future<void> markAsSynced(List<String> surveyIds) async {
    if (surveyIds.isEmpty) return;
    final set = surveyIds.toSet();
    final all = await _getAllSubmissions();
    for (var i = 0; i < all.length; i++) {
      if (set.contains(all[i].id)) {
        all[i] = PendingSurveySubmissionModel(
          id: all[i].id,
          responses: all[i].responses,
          createdAt: all[i].createdAt,
          synced: true,
        );
      }
    }
    await _box.write(
      _surveyBoxKey,
      all.map((e) => e.toJson()).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> _getEngagementResponses() async {
    final raw = _box.read(_engagementResponsesKey);
    if (raw == null) return [];
    final list = raw as List<dynamic>;
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> saveEngagementResponse(
    Map<String, dynamic> response,
  ) async {
    final saved = Map<String, dynamic>.from(response);
    saved.putIfAbsent(
      'saved_at',
      () => DateTime.now().toIso8601String(),
    );
    final list = await _getEngagementResponses();
    list.add(saved);
    await _box.write(_engagementResponsesKey, list);
    return saved;
  }

  @override
  Future<int> getEngagementResponseCount() async {
    final stats = await getEngagementResponseStats();
    return stats.total;
  }

  static bool isSuccessfulResponse(Map<String, dynamic> record) {
    final status = record['status']?.toString();
    if (status == 'success') return true;
    if (status == 'failed' || status == 'pending') return false;
    return record['uploaded'] == true;
  }

  @override
  Future<EngagementResponseStats> getEngagementResponseStats() async {
    final list = await _getEngagementResponses();
    final success = list.where(isSuccessfulResponse).length;
    return EngagementResponseStats(total: list.length, success: success);
  }

  @override
  Future<List<Map<String, dynamic>>> getEngagementResponsesPendingSync() async {
    final list = await _getEngagementResponses();
    return list.where((r) => !isSuccessfulResponse(r)).toList();
  }

  @override
  Future<Map<String, dynamic>> updateEngagementResponseStatus({
    required String localId,
    required String status,
  }) async {
    final list = await _getEngagementResponses();
    final index = list.indexWhere(
      (e) => e['local_id']?.toString() == localId,
    );
    if (index < 0) {
      throw StateError('Engagement response not found: $localId');
    }

    final updated = <String, dynamic>{
      ...list[index],
      'status': status,
      'uploaded': status == 'success',
    };
    if (status == 'success') {
      updated['uploaded_at'] = DateTime.now().toIso8601String();
    }

    list[index] = updated;
    await _box.write(_engagementResponsesKey, list);
    return updated;
  }

  @override
  Future<void> saveCachedSurveys(List<SurveyModel> surveys) async {
    await _box.write(
      _cachedEngagementSurveysKey,
      surveys.map((s) => s.toJson()).toList(),
    );
  }

  @override
  Future<List<SurveyModel>> getCachedSurveys() async {
    final raw = _box.read(_cachedEngagementSurveysKey);
    if (raw == null) return [];
    final list = raw as List<dynamic>;
    return list
        .map(
          (item) => SurveyModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
