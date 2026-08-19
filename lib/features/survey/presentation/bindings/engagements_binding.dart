import 'package:get/get.dart';
import 'package:tisini/features/survey/data/datasources/survey_local_data_source.dart';
import 'package:tisini/features/survey/data/datasources/survey_remote_source.dart';
import 'package:tisini/features/survey/data/repositories/survey_repository_impl.dart';
import 'package:tisini/features/survey/domain/repositories/survey_repository.dart';
import 'package:tisini/features/survey/domain/usecases/cached_survey.dart';
import 'package:tisini/features/survey/domain/usecases/fetch_survey.dart';
import 'package:tisini/features/survey/presentation/controllers/engagements_controller.dart';

class EngagementsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SurveyLocalDataSource>()) {
      Get.lazyPut<SurveyLocalDataSource>(() => SurveyLocalDataSourceImpl());
    }
    if (!Get.isRegistered<SurveyRemoteSource>()) {
      Get.lazyPut<SurveyRemoteSource>(() => SurveyRemoteSourceImpl());
    }
    if (!Get.isRegistered<SurveyRepository>()) {
      Get.lazyPut<SurveyRepository>(
        () => SurveyRepositoryImpl(
          localDataSource: Get.find(),
          remoteDataSource: Get.find(),
        ),
      );
    }

    Get.lazyPut(() => FetchSurveyUsecase(repository: Get.find()));
    Get.lazyPut(() => SaveCachedSurveysUsecase(repository: Get.find()));
    Get.lazyPut(() => GetCachedSurveysUsecase(repository: Get.find()));

    Get.lazyPut<EngagementsController>(
      () => EngagementsController(
        fetchSurveysUseCase: Get.find(),
        saveCachedSurveysUsecase: Get.find(),
        getCachedSurveysUsecase: Get.find(),
      ),
    );
  }
}
