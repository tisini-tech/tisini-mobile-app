import 'package:get/get.dart';
import 'package:tisini/features/survey/data/datasources/survey_local_data_source.dart';
import 'package:tisini/features/survey/data/datasources/survey_remote_source.dart';
import 'package:tisini/features/survey/data/repositories/survey_repository_impl.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';
import 'package:tisini/features/survey/domain/usecases/cached_survey.dart';
import 'package:tisini/features/survey/domain/usecases/fetch_survey.dart';
import 'package:tisini/features/survey/domain/usecases/get_engagement_response_stats.dart';
import 'package:tisini/features/survey/domain/usecases/sync_pending_engagement_responses.dart';
import 'package:tisini/features/survey/domain/usecases/get_last_referral_code.dart';
import 'package:tisini/features/survey/domain/usecases/save_engagement_response_locally.dart';
import 'package:tisini/features/survey/domain/usecases/update_engagement_response_status.dart';
import 'package:tisini/features/survey/domain/usecases/save_last_referral_code.dart';
import 'package:tisini/features/survey/domain/usecases/submit_survey.dart';
import 'package:tisini/features/survey/presentation/controllers/engagement_controller.dart';

class EngagementBinding extends Bindings {
  @override
  void dependencies() {
    // Data layer
    Get.lazyPut<SurveyLocalDataSource>(() => SurveyLocalDataSourceImpl());
    Get.lazyPut<SurveyRemoteSource>(() => SurveyRemoteSourceImpl());
    Get.lazyPut<SurveyRepository>(
      () => SurveyRepositoryImpl(
        localDataSource: Get.find(),
        remoteDataSource: Get.find(),
      ),
    );

    // Domain layer
    Get.lazyPut(() => FetchSurveyUsecase(repository: Get.find()));
    Get.lazyPut(() => SaveCachedSurveysUsecase(repository: Get.find()));
    Get.lazyPut(() => GetCachedSurveysUsecase(repository: Get.find()));
    Get.lazyPut(() => GetLastReferralCode(repository: Get.find()));
    Get.lazyPut(() => SaveLastReferralCode(repository: Get.find()));
    Get.lazyPut(() => SubmitSurveyUsecase(repository: Get.find()));
    Get.lazyPut(() => SaveEngagementResponseLocally(repository: Get.find()));
    Get.lazyPut(() => UpdateEngagementResponseStatus(repository: Get.find()));
    Get.lazyPut(() => GetEngagementResponseStats(repository: Get.find()));
    Get.lazyPut(() => SyncPendingEngagementResponses(repository: Get.find()));

    // Presentation layer – register with explicit type so Get.find<EngagementController>() resolves
    Get.lazyPut<EngagementController>(
      () => EngagementController(
        fetchSurveyUsecase: Get.find(),
        saveCachedSurveysUsecase: Get.find(),
        getCachedSurveysUsecase: Get.find(),
        getLastReferralCode: Get.find(),
        saveLastReferralCode: Get.find(),
        submitSurveyUsecase: Get.find(),
        saveEngagementResponseLocally: Get.find(),
        updateEngagementResponseStatus: Get.find(),
        getEngagementResponseStats: Get.find(),
        syncPendingEngagementResponses: Get.find(),
      ),
    );
  }
}
