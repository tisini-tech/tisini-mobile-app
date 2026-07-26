import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/survey.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/survey/domain/entities/engagement.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';
import 'package:tisini/features/survey/domain/usecases/cached_survey.dart';
import 'package:tisini/features/survey/domain/usecases/fetch_survey.dart';
import 'package:tisini/features/survey/domain/usecases/get_engagement_response_stats.dart';
import 'package:tisini/features/survey/domain/usecases/sync_pending_engagement_responses.dart';
import 'package:tisini/features/survey/domain/usecases/get_last_referral_code.dart';
import 'package:tisini/features/survey/domain/usecases/save_engagement_response_locally.dart';
import 'package:tisini/features/survey/domain/usecases/update_engagement_response_status.dart';
import 'package:tisini/features/survey/domain/usecases/save_last_referral_code.dart';
import 'package:tisini/features/survey/domain/usecases/submit_survey.dart';
import 'package:tisini/features/survey/presentation/widgets/referral_code_dialog.dart';

class EngagementController extends GetxController
    implements SurveyFormDelegate {
  static EngagementController get instance => Get.find();

  final FetchSurveyUsecase fetchSurveyUsecase;
  final SaveCachedSurveysUsecase saveCachedSurveysUsecase;
  final GetCachedSurveysUsecase getCachedSurveysUsecase;
  final GetLastReferralCode getLastReferralCode;
  final SaveLastReferralCode saveLastReferralCode;
  final SubmitSurveyUsecase submitSurveyUsecase;
  final SaveEngagementResponseLocally saveEngagementResponseLocally;
  final UpdateEngagementResponseStatus updateEngagementResponseStatus;
  final GetEngagementResponseStats getEngagementResponseStats;
  final SyncPendingEngagementResponses syncPendingEngagementResponses;

  EngagementController({
    required this.fetchSurveyUsecase,
    required this.saveCachedSurveysUsecase,
    required this.getCachedSurveysUsecase,
    required this.getLastReferralCode,
    required this.saveLastReferralCode,
    required this.submitSurveyUsecase,
    required this.saveEngagementResponseLocally,
    required this.updateEngagementResponseStatus,
    required this.getEngagementResponseStats,
    required this.syncPendingEngagementResponses,
  });

  final RxList<Survey> surveys = <Survey>[].obs;

  /// questionId (int) or contact field key -> value
  final Rx<Map<Object, dynamic>> answers = Rx<Map<Object, dynamic>>({});

  final RxInt currentQuestionIndex = 0.obs;

  final RxInt _surveyFormVersionRx = 0.obs;

  final RxString referralCode = ''.obs;

  final RxInt successResponses = 0.obs;
  final RxInt totalResponses = 0.obs;
  final RxBool isSyncing = false.obs;

  String get surveyTitle => surveys.isNotEmpty ? surveys.first.title : 'Survey';

  @override
  int get surveyFormVersion => _surveyFormVersionRx.value;

  @override
  void onInit() {
    super.onInit();

    fetchSurvey();
    _loadLastReferralCode();
    refreshResponseStats();

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _showReferralCodeDialog(),
    );
  }

  Future<void> refreshResponseStats() async {
    final result = await getEngagementResponseStats(const NoParams());
    result.fold((_) {}, (stats) {
      successResponses.value = stats.success;
      totalResponses.value = stats.total;
    });
  }

  Future<void> syncPendingResponses() async {
    final pending = totalResponses.value - successResponses.value;
    if (pending <= 0) {
      showSnackbar('Sync', 'No responses to sync.', TColors.textSecondary);
      return;
    }

    isSyncing.value = true;
    final result = await syncPendingEngagementResponses(const NoParams());
    isSyncing.value = false;

    result.fold(
      (failure) => showSnackbar('Sync failed', failure.message, TColors.error),
      (message) {
        refreshResponseStats();
        showSnackbar('Sync', message, TColors.success);
      },
    );
  }

  Future<void> _loadLastReferralCode() async {
    final result = await getLastReferralCode(const NoParams());
    result.fold((_) {}, (code) {
      if (code != null && code.trim().isNotEmpty) {
        referralCode.value = code.trim();
      }
    });
  }

  Future<void> _showReferralCodeDialog() async {
    final context = Get.context;
    if (context == null || !context.mounted) return;
    final result = await Get.dialog<String>(
      ReferralCodeDialog(initialValue: referralCode.value),
      barrierDismissible: false,
    );
    if (result != null) {
      referralCode.value = result;
      saveLastReferralCode(
        SaveLastReferralCodeParams(code: result),
      ).then((_) {});
    }
  }

  /// Call this to show the referral code dialog again (e.g. from app bar).
  void showReferralCodeDialog() => _showReferralCodeDialog();

  Future<void> fetchSurvey() async {
    final result = await fetchSurveyUsecase(const NoParams());

    await result.fold(
      (failure) async {
        final cached = await getCachedSurveysUsecase(const NoParams());
        cached.fold(
          (_) => showSnackbar('Error', failure.message, TColors.error),
          (list) {
            if (list.isEmpty) {
              showSnackbar('Error', failure.message, TColors.error);
              return;
            }
            surveys.assignAll(list);
            showSnackbar('Offline', 'Showing last saved survey.', TColors.info);
          },
        );
      },
      (list) async {
        surveys.assignAll(list);
        await saveCachedSurveysUsecase(SaveCachedSurveysParams(surveys: list));
      },
    );
  }

  /// Flatten all engagements from all surveys into Question list (for UI).
  List<Question> get visibleQuestions {
    final out = <Question>[];
    int id = 1;
    for (final survey in surveys) {
      for (final e in survey.engagements) {
        out.add(_engagementToQuestion(e, id++));
      }
    }
    return out;
  }

  int get totalQuestions => visibleQuestions.length;

  bool get isFirstQuestion => currentQuestionIndex.value <= 0;

  bool get isLastQuestion =>
      totalQuestions > 0 && currentQuestionIndex.value >= totalQuestions - 1;

  Question? get currentQuestion {
    final list = visibleQuestions;
    var i = currentQuestionIndex.value;
    if (list.isEmpty) return null;
    if (i < 0) i = 0;
    if (i >= list.length) {
      currentQuestionIndex.value = list.length - 1;
      i = list.length - 1;
    }
    return list[i];
  }

  void goToNextQuestion() {
    final q = currentQuestion;
    if (q != null) {
      final err = validateRequired(q);
      if (err != null) {
        showSnackbar('Required', err, TColors.error);
        return;
      }
    }
    if (currentQuestionIndex.value < totalQuestions - 1) {
      currentQuestionIndex.value++;
    }
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void resetWizard() {
    currentQuestionIndex.value = 0;
  }

  Future<void> submitEngagement() async {
    final q = currentQuestion;
    if (q != null) {
      final err = validateRequired(q);
      if (err != null) {
        showSnackbar('Required', err, TColors.error);
        return;
      }
    }
    // Log answers before clearing; keys may be int (question id) or String (contact keys)
    final payload = <String, dynamic>{
      for (final e in answers.value.entries) e.key.toString(): e.value,
    };
    debugPrint('Engagement answers: $payload');

    // Save response locally for count/history
    final saved = await saveEngagementResponseLocally(
      SaveEngagementResponseLocallyParams(
        response: {
          ...payload,
          'referral_code': referralCode.value,
          'survey_id': surveys[0].id,
          'saved_at': DateTime.now().toIso8601String(),
          'local_id': 'engmt_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'pending',
          'uploaded': false,
        },
      ),
    );

    await saved.fold(
      (failure) async {
        showSnackbar('Error', failure.message, TColors.error);
      },
      (savedSurvey) async {
        debugPrint('Engagement saved locally: $savedSurvey');
        refreshResponseStats();

        answers.value = {};
        _surveyFormVersionRx.value++;
        resetWizard();

        final localId = savedSurvey['local_id']?.toString() ?? '';
        final savedAt = savedSurvey['saved_at']?.toString() ?? '';

        final result = await submitSurveyUsecase(
          SubmitSurveyParams(
            survey: payload,
            code: referralCode.value,
            surveyId: surveys[0].id,
            localId: localId,
            savedAt: savedAt,
          ),
        );

        await result.fold(
          (failure) async {
            await _persistEngagementUploadStatus(
              localId: localId,
              status: 'failed',
            );
            showSnackbar(
              'Error',
              'Failed to upload engagement response to server. It will be retried later.',
              TColors.info,
            );
          },
          (message) async {
            await _persistEngagementUploadStatus(
              localId: localId,
              status: 'success',
            );
            showSnackbar('Survey', message, TColors.success);
            refreshResponseStats();
          },
        );
      },
    );
  }

  Future<void> _persistEngagementUploadStatus({
    required String localId,
    required String status,
  }) async {
    if (localId.isEmpty) return;

    final updated = await updateEngagementResponseStatus(
      UpdateEngagementResponseStatusParams(localId: localId, status: status),
    );
    updated.fold(
      (failure) =>
          debugPrint('Failed to update engagement status: ${failure.message}'),
      (record) => debugPrint('Engagement status persisted: $record'),
    );
  }

  static Question _engagementToQuestion(Engagement e, int id) {
    final isRequired = e.isRequired == '1' || e.isRequired == 'true';
    final multiline = e.multiline == '1' || e.multiline == 'true';
    final multiple = e.multiple == '1' || e.multiple == 'true';
    final other = e.other == '1' || e.other == 'true';
    int? maxSelections;
    if (e.maxSelections != null) {
      if (e.maxSelections is int) {
        maxSelections = e.maxSelections as int;
      } else {
        maxSelections = int.tryParse(e.maxSelections.toString());
      }
    }
    List<Map<String, String>>? fields;
    if (e.fields is List) {
      final list = e.fields as List;
      fields = list
          .map(
            (f) => (f is Map
                ? Map<String, String>.from(
                    f.map(
                      (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
                    ),
                  )
                : <String, String>{}),
          )
          .where((m) => m.isNotEmpty)
          .toList();
    }

    String type = e.type.toLowerCase();
    if (type == 'choices') type = 'choice';

    return Question(
      id: id,
      question: e.question,
      type: type,
      isRequired: isRequired,
      placeholder: e.placeholder.isEmpty ? null : e.placeholder,
      multiline: multiline,
      options: e.options.isEmpty ? null : e.options,
      multiple: multiple,
      helpText: e.helpText.isEmpty ? null : e.helpText,
      maxSelections: maxSelections,
      layout: e.layout.isEmpty ? null : e.layout,
      other: other,
      fields: fields,
    );
  }

  @override
  void setAnswer(Object questionIdOrKey, dynamic value) {
    final map = Map<Object, dynamic>.from(answers.value);
    if (value == null ||
        (value is String && value.isEmpty) ||
        (value is List && value.isEmpty)) {
      map.remove(questionIdOrKey);
    } else {
      map[questionIdOrKey] = value;
    }
    answers.value = map;
  }

  @override
  String? getAnswerString(Object questionIdOrKey) {
    final v = answers.value[questionIdOrKey];
    if (v == null) return null;
    return v is String ? v : (v as List).join(', ');
  }

  @override
  List<String>? getAnswerList(Object questionId) {
    final v = answers.value[questionId];
    if (v == null) return null;
    if (v is List) return List<String>.from(v.map((e) => e.toString()));
    return [v.toString()];
  }

  @override
  String? validateRequired(Question q) {
    if (!q.isRequired) return null;
    if (q.type == 'contact') {
      final fields = q.fields ?? [];
      for (final f in fields) {
        final name = f['name'];
        if (name != null) {
          final key = '${q.id}_$name';
          final v = answers.value[key];
          if (v == null || (v is String && v.trim().isEmpty)) {
            return '${f['label']} is required';
          }
        }
      }
      return null;
    }
    final v = answers.value[q.id];
    final answered =
        v != null &&
        (v is String ? v.trim().isNotEmpty : (v as List).isNotEmpty);
    if (!answered) return 'This question is required';
    if (q.maxSelections != null && q.options != null) {
      final list = getAnswerList(q.id);
      if (list != null && list.length > q.maxSelections!) {
        return 'Select at most ${q.maxSelections} options';
      }
    }
    return null;
  }
}
