import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/feedback_controller.dart';

class FeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedbackController());
  }
}
