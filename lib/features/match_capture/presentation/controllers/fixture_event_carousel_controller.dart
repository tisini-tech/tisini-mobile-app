import 'dart:async';

import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_data.dart';

/// Cycles through [MatchCaptureController.fixtureData] for the stats app bar.
/// Sub-events on [MatchData] are not shown — only [homeCount], [eventName], [awayCount].
class FixtureEventCarouselController extends GetxController {
  static const carouselInterval = Duration(seconds: 4);

  MatchCaptureController get _matchCapture => Get.find();

  final RxList<MatchData> events = <MatchData>[].obs;
  final RxInt currentIndex = 0.obs;

  Timer? _timer;
  Worker? _fixtureDataWorker;

  MatchData? get currentEvent {
    if (events.isEmpty) return null;
    return events[currentIndex.value % events.length];
  }

  @override
  void onInit() {
    super.onInit();
    _applyFixtureData(_matchCapture.fixtureData.value);
    _fixtureDataWorker = ever<List<MatchData>?>(
      _matchCapture.fixtureData,
      _applyFixtureData,
    );
    _startCarousel();
  }

  void _applyFixtureData(List<MatchData>? data) {
    events.assignAll(data ?? []);
    if (events.isEmpty) {
      currentIndex.value = 0;
    } else if (currentIndex.value >= events.length) {
      currentIndex.value = 0;
    }
  }

  void _startCarousel() {
    _timer?.cancel();
    _timer = Timer.periodic(carouselInterval, (_) {
      if (events.isEmpty) return;
      currentIndex.value = (currentIndex.value + 1) % events.length;
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _fixtureDataWorker?.dispose();
    super.onClose();
  }
}
