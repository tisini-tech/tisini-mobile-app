import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/officals_controller.dart';

class MatchOfficialsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatchOfficialsController());
  }
}
