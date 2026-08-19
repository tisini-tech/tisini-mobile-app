import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';
import 'package:tisini/features/survey/domain/usecases/cached_survey.dart';
import 'package:tisini/features/survey/domain/usecases/fetch_survey.dart';

enum SurveyScheduleStatus { upcoming, open, ended }

class EngagementsController extends GetxController {
  static EngagementsController get to => Get.find();

  final FetchSurveyUsecase fetchSurveysUseCase;
  final SaveCachedSurveysUsecase saveCachedSurveysUsecase;
  final GetCachedSurveysUsecase getCachedSurveysUsecase;

  EngagementsController({
    required this.fetchSurveysUseCase,
    required this.saveCachedSurveysUsecase,
    required this.getCachedSurveysUsecase,
  });

  final RxList<Survey> surveys = <Survey>[].obs;
  final RxBool isLoading = false.obs;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void onInit() {
    super.onInit();
    fetchSurveys();
  }

  Future<void> fetchSurveys() async {
    isLoading.value = true;
    final result = await fetchSurveysUseCase(const NoParams());
    isLoading.value = false;

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
            showSnackbar('Offline', 'Showing saved surveys.', TColors.info);
          },
        );
      },
      (list) async {
        surveys.assignAll(list);
        await saveCachedSurveysUsecase(SaveCachedSurveysParams(surveys: list));
      },
    );
  }

  /// Status from [Survey.startsAt] / [Survey.endsAt] (date from → date to).
  SurveyScheduleStatus scheduleStatus(Survey survey, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (current.isBefore(survey.startsAt)) {
      return SurveyScheduleStatus.upcoming;
    }
    if (current.isAfter(survey.endsAt)) {
      return SurveyScheduleStatus.ended;
    }
    return SurveyScheduleStatus.open;
  }

  String scheduleStatusLabel(Survey survey) {
    return switch (scheduleStatus(survey)) {
      SurveyScheduleStatus.upcoming => 'Upcoming',
      SurveyScheduleStatus.open => 'Open',
      SurveyScheduleStatus.ended => 'Ended',
    };
  }

  String dateRangeLabel(Survey survey) {
    return '${_dateFormat.format(survey.startsAt.toLocal())}'
        ' – '
        '${_dateFormat.format(survey.endsAt.toLocal())}';
  }

  void openSurvey(Survey survey) {
    if (scheduleStatus(survey) == SurveyScheduleStatus.ended) {
      showSnackbar(
        'Survey',
        'This survey has ended.',
        TColors.textSecondary,
      );
      return;
    }
    Get.toNamed('/engagement', arguments: survey.id.toString());
  }
}
