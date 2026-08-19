import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/survey/domain/entities/questions.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';
import 'package:tisini/features/survey/domain/usecases/cached_survey.dart';
import 'package:tisini/features/survey/domain/usecases/fetch_survey.dart';
import 'package:tisini/features/survey/domain/usecases/get_engagement_response_stats.dart';
import 'package:tisini/features/survey/domain/usecases/get_last_referral_code.dart';
import 'package:tisini/features/survey/domain/usecases/save_engagement_response_locally.dart';
import 'package:tisini/features/survey/domain/usecases/save_last_referral_code.dart';
import 'package:tisini/features/survey/domain/usecases/submit_survey.dart';
import 'package:tisini/features/survey/domain/usecases/sync_pending_engagement_responses.dart';
import 'package:tisini/features/survey/domain/usecases/update_engagement_response_status.dart';
import 'package:tisini/features/survey/presentation/widgets/referral_code_dialog.dart';

class EngagementController extends GetxController {
  static EngagementController get to => Get.find();

  static const answerTypeSingle = 'SA';
  static const answerTypeMultiple = 'MA';
  static const answerTypeFreeText = 'FT';

  final FetchSurveyQuestionsUsecase fetchSurveyQuestionsUsecase;
  final UpsertCachedSurveyUsecase upsertCachedSurveyUsecase;
  final GetCachedSurveyByIdUsecase getCachedSurveyByIdUsecase;
  final GetLastReferralCode getLastReferralCode;
  final SaveLastReferralCode saveLastReferralCode;
  final SubmitSurveyUsecase submitSurveyUsecase;
  final SaveEngagementResponseLocally saveEngagementResponseLocally;
  final UpdateEngagementResponseStatus updateEngagementResponseStatus;
  final GetEngagementResponseStats getEngagementResponseStats;
  final SyncPendingEngagementResponses syncPendingEngagementResponses;

  EngagementController({
    required this.fetchSurveyQuestionsUsecase,
    required this.upsertCachedSurveyUsecase,
    required this.getCachedSurveyByIdUsecase,
    required this.getLastReferralCode,
    required this.saveLastReferralCode,
    required this.submitSurveyUsecase,
    required this.saveEngagementResponseLocally,
    required this.updateEngagementResponseStatus,
    required this.getEngagementResponseStats,
    required this.syncPendingEngagementResponses,
  });

  late final String surveyId;

  final Rxn<Survey> survey = Rxn<Survey>();
  final RxBool isLoading = false.obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxString surveyer = ''.obs;
  final RxInt formVersion = 0.obs;

  final RxInt successResponses = 0.obs;
  final RxInt totalResponses = 0.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isSubmitting = false.obs;

  /// questionId → answer payload item
  final RxMap<int, Map<String, dynamic>> answers =
      <int, Map<String, dynamic>>{}.obs;

  DateTime? _questionStartedAt;

  List<Questions> get questions {
    final list = [...(survey.value?.questions ?? const <Questions>[])];
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  int get totalQuestions => questions.length;

  Questions? get currentQuestion {
    final list = questions;
    if (list.isEmpty) return null;
    final index = currentQuestionIndex.value.clamp(0, list.length - 1);
    return list[index];
  }

  bool get isFirstQuestion => currentQuestionIndex.value <= 0;

  bool get isLastQuestion =>
      totalQuestions > 0 && currentQuestionIndex.value >= totalQuestions - 1;

  String get surveyTitle => survey.value?.title ?? 'Survey';

  int get pendingResponses =>
      (totalResponses.value - successResponses.value).clamp(0, 1 << 30);

  @override
  void onInit() {
    super.onInit();
    surveyId = _parseSurveyId(Get.arguments);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadLastSurveyer();
    await refreshResponseStats();
    await fetchSurveyQuestions();
    if (surveyer.value.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showSurveyerDialog(requireValue: true);
      });
    }
  }

  String _parseSurveyId(dynamic args) {
    if (args is Survey) return args.id.toString();
    if (args is int) return args.toString();
    if (args is String && args.trim().isNotEmpty) return args.trim();
    return '';
  }

  Future<void> _loadLastSurveyer() async {
    final result = await getLastReferralCode(const NoParams());
    result.fold((_) {}, (code) {
      if (code != null && code.trim().isNotEmpty) {
        surveyer.value = code.trim();
      }
    });
  }

  Future<void> refreshResponseStats() async {
    final result = await getEngagementResponseStats(const NoParams());
    result.fold((_) {}, (stats) {
      successResponses.value = stats.success;
      totalResponses.value = stats.total;
    });
  }

  Future<void> syncPendingResponses() async {
    if (pendingResponses <= 0) {
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

  Future<void> _showSurveyerDialog({bool requireValue = false}) async {
    final context = Get.context;
    if (context == null || !context.mounted) return;

    final result = await Get.dialog<String>(
      ReferralCodeDialog(
        initialValue: surveyer.value,
        title: 'Surveyer',
        hintText: 'Enter surveyer id',
        showSkip: !requireValue && surveyer.value.isNotEmpty,
      ),
      barrierDismissible: !requireValue,
    );

    if (result != null && result.isNotEmpty) {
      surveyer.value = result;
      await saveLastReferralCode(SaveLastReferralCodeParams(code: result));
      return;
    }

    if (requireValue && surveyer.value.isEmpty) {
      showSnackbar('Survey', 'Surveyer is required', TColors.error);
      await _showSurveyerDialog(requireValue: true);
    }
  }

  /// Re-open surveyer dialog (e.g. from app bar).
  void showSurveyerDialog() => _showSurveyerDialog();

  Future<void> fetchSurveyQuestions() async {
    if (surveyId.isEmpty) {
      showSnackbar('Error', 'Missing survey id', TColors.error);
      return;
    }

    isLoading.value = true;
    final result = await fetchSurveyQuestionsUsecase(
      SurveyParams(surveyId: surveyId),
    );
    isLoading.value = false;

    await result.fold(
      (failure) async {
        final cached = await getCachedSurveyByIdUsecase(
          GetCachedSurveyByIdParams(surveyId: surveyId),
        );
        cached.fold(
          (_) => showSnackbar('Error', failure.message, TColors.error),
          (data) {
            if (data == null || data.questions.isEmpty) {
              showSnackbar(
                'Offline',
                'Survey not saved on this device. Open it online first.',
                TColors.error,
              );
              return;
            }
            _applySurvey(data);
            showSnackbar('Offline', 'Showing saved survey.', TColors.info);
          },
        );
      },
      (data) async {
        _applySurvey(data);
        await upsertCachedSurveyUsecase(UpsertCachedSurveyParams(survey: data));
      },
    );
  }

  void _applySurvey(Survey data) {
    survey.value = data;
    answers.clear();
    currentQuestionIndex.value = 0;
    formVersion.value++;
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionStartedAt = DateTime.now();
  }

  void _commitResponseMs(int questionId) {
    final started = _questionStartedAt;
    if (started == null) return;
    final answer = _ensureAnswer(questionId);
    answer['response_ms'] = DateTime.now().difference(started).inMilliseconds;
  }

  String _generateLocalId() {
    final rand = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return 'offline-${DateTime.now().millisecondsSinceEpoch}-$rand';
  }

  Map<String, dynamic> _ensureAnswer(int questionId) {
    return answers.putIfAbsent(
      questionId,
      () => <String, dynamic>{
        'question_id': questionId,
        'choice_id': null,
        'selected_choice_ids': <int>[],
        'text_answer': null,
        'response_ms': 0,
        'surveyer': surveyer.value,
        'local_id': _generateLocalId(),
        'sync_status': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  void goToPreviousQuestion() {
    if (isFirstQuestion) return;
    final current = currentQuestion;
    if (current != null) _commitResponseMs(current.id);
    currentQuestionIndex.value--;
    _startQuestionTimer();
  }

  void goToNextQuestion() {
    final question = currentQuestion;
    if (question == null) return;

    final error = validateQuestion(question);
    if (error != null) {
      showSnackbar('Survey', error, TColors.error);
      return;
    }

    _commitResponseMs(question.id);
    if (isLastQuestion) return;
    currentQuestionIndex.value++;
    _startQuestionTimer();
  }

  void selectSingleChoice(int questionId, int choiceId) {
    final answer = _ensureAnswer(questionId);
    answer['choice_id'] = choiceId;
    answer['selected_choice_ids'] = <int>[];
    answer['text_answer'] = null;
    answer['surveyer'] = surveyer.value;
    _commitResponseMs(questionId);
    answers.refresh();
  }

  void toggleMultipleChoice(int questionId, int choiceId) {
    final answer = _ensureAnswer(questionId);
    final selected = List<int>.from(
      (answer['selected_choice_ids'] as List?)?.whereType<int>() ?? const [],
    );

    if (selected.contains(choiceId)) {
      selected.remove(choiceId);
    } else {
      selected.add(choiceId);
    }

    answer['selected_choice_ids'] = selected;
    answer['choice_id'] = null;
    answer['text_answer'] = null;
    answer['surveyer'] = surveyer.value;
    _commitResponseMs(questionId);
    answers.refresh();
  }

  void setFreeText(int questionId, String value) {
    final answer = _ensureAnswer(questionId);
    answer['text_answer'] = value;
    answer['choice_id'] = null;
    answer['selected_choice_ids'] = <int>[];
    answer['surveyer'] = surveyer.value;
    _commitResponseMs(questionId);
    answers.refresh();
  }

  bool isChoiceSelected(Questions question, int choiceId) {
    final answer = answers[question.id];
    if (answer == null) return false;

    if (question.answerType == answerTypeSingle) {
      return answer['choice_id'] == choiceId;
    }
    if (question.answerType == answerTypeMultiple) {
      final selected = answer['selected_choice_ids'];
      return selected is List && selected.contains(choiceId);
    }
    return false;
  }

  String freeTextValue(int questionId) {
    final answer = answers[questionId];
    final text = answer?['text_answer'];
    return text is String ? text : '';
  }

  String? validateQuestion(Questions question) {
    if (!question.isRequired) return null;

    final answer = answers[question.id];
    switch (question.answerType) {
      case answerTypeSingle:
        if (answer?['choice_id'] is! int) return 'Please select an option';
      case answerTypeMultiple:
        final selected = answer?['selected_choice_ids'];
        if (selected is! List || selected.isEmpty) {
          return 'Please select at least one option';
        }
      case answerTypeFreeText:
        final text = answer?['text_answer'];
        if (text is! String || text.trim().isEmpty) {
          return 'Please enter your answer';
        }
      default:
        if (answer == null) return 'Please answer this question';
    }
    return null;
  }

  String? validateAnswers() {
    if (surveyer.value.trim().isEmpty) {
      return 'Surveyer is required';
    }
    for (final question in questions) {
      final error = validateQuestion(question);
      if (error != null) {
        return '${question.text}: $error';
      }
    }
    return null;
  }

  Map<String, dynamic> _baseMeta(
    Map<String, dynamic>? answer, {
    required int syncStatus,
  }) {
    return {
      'surveyer': answer?['surveyer'] ?? surveyer.value,
      'local_id': answer?['local_id'] ?? _generateLocalId(),
      'sync_status': syncStatus,
      'created_at':
          answer?['created_at'] ??
          answer?['createdAt'] ??
          DateTime.now().toIso8601String(),
    };
  }

  /// API body: array of answer objects.
  List<Map<String, dynamic>> buildAnswersPayload({int syncStatus = 0}) {
    return questions.map((question) {
      final answer = answers[question.id];
      final responseMs = answer?['response_ms'] ?? 0;
      final item = <String, dynamic>{
        'question_id': question.id,
        'response_ms': responseMs,
        ..._baseMeta(answer, syncStatus: syncStatus),
      };

      switch (question.answerType) {
        case answerTypeSingle:
          item['choice_id'] = answer?['choice_id'];
        case answerTypeMultiple:
          item['selected_choice_ids'] = List<int>.from(
            (answer?['selected_choice_ids'] as List?)?.whereType<int>() ??
                const [],
          );
        case answerTypeFreeText:
          item['text_answer'] = answer?['text_answer'];
        default:
          if (answer?['choice_id'] != null) {
            item['choice_id'] = answer?['choice_id'];
          }
          final selected = answer?['selected_choice_ids'];
          if (selected is List && selected.isNotEmpty) {
            item['selected_choice_ids'] = List<int>.from(
              selected.whereType<int>(),
            );
          }
          if (answer?['text_answer'] != null) {
            item['text_answer'] = answer?['text_answer'];
          }
      }

      return item;
    }).toList();
  }

  Future<void> submit() async {
    final error = validateAnswers();
    if (error != null) {
      showSnackbar('Survey', error, TColors.error);
      if (surveyer.value.trim().isEmpty) {
        _showSurveyerDialog(requireValue: true);
      }
      return;
    }

    if (isSubmitting.value) return;
    isSubmitting.value = true;

    final current = currentQuestion;
    if (current != null) _commitResponseMs(current.id);

    // Online attempt uses sync_status 0; local pending copy uses 1.
    final onlinePayload = buildAnswersPayload(syncStatus: 0);
    final pendingPayload = buildAnswersPayload(syncStatus: 1);
    final responseLocalId = _generateLocalId();

    final saved = await saveEngagementResponseLocally(
      SaveEngagementResponseLocallyParams(
        response: {
          'survey_id': surveyId,
          'local_id': responseLocalId,
          'answers': pendingPayload,
          'sync_status': 1,
          'status': 'pending',
          'uploaded': false,
          'saved_at': DateTime.now().toIso8601String(),
          'surveyer': surveyer.value,
        },
      ),
    );

    await saved.fold(
      (failure) async {
        showSnackbar('Error', failure.message, TColors.error);
      },
      (savedRecord) async {
        debugPrint('Engagement saved locally: $savedRecord');
        await refreshResponseStats();
        _resetForNewResponse();

        final result = await submitSurveyUsecase(
          SubmitSurveyParams(survey: onlinePayload, surveyId: surveyId),
        );

        await result.fold(
          (failure) async {
            await _persistUploadStatus(
              localId: responseLocalId,
              status: 'failed',
            );
            showSnackbar(
              'Saved offline',
              'Upload failed. Response kept locally (sync_status=1) for later sync.',
              TColors.info,
            );
          },
          (message) async {
            await _persistUploadStatus(
              localId: responseLocalId,
              status: 'success',
            );
            showSnackbar('Survey', message, TColors.success);
          },
        );
        await refreshResponseStats();
      },
    );

    isSubmitting.value = false;
  }

  Future<void> _persistUploadStatus({
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

  /// Clears answers and returns to the first question for another response.
  void _resetForNewResponse() {
    answers.clear();
    currentQuestionIndex.value = 0;
    formVersion.value++;
    _startQuestionTimer();
  }
}
