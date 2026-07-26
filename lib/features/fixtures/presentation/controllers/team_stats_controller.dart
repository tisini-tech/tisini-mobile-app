import 'package:get/get.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/fixtures/presentation/controllers/agent_fixture_controller.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_data.dart';
import 'package:tisini/shared/fixture_data/domain/usecases/match_data_usecase.dart';

class TeamStatsController extends GetxController {
  final GetMatchDataUsecase matchDataUsecase;

  TeamStatsController({required this.matchDataUsecase});

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxList<MatchData> stats = <MatchData>[].obs;
  final RxList<int> expandedEventIds = <int>[].obs;
  final Rx<AgentFixture?> activeFixture = Rx<AgentFixture?>(null);

  AgentFixture? get fixture => activeFixture.value;

  void toggleExpanded(int eventId) {
    if (expandedEventIds.contains(eventId)) {
      expandedEventIds.remove(eventId);
    } else {
      expandedEventIds.add(eventId);
    }
  }

  bool isExpanded(int eventId) => expandedEventIds.contains(eventId);

  @override
  void onInit() {
    super.onInit();
    activeFixture.value = _resolveInitialFixture();
    refresh();
  }

  AgentFixture? _resolveInitialFixture() {
    final args = Get.arguments;
    if (args is AgentFixture) return args;

    if (Get.isRegistered<AgentFixtureController>()) {
      return AgentFixtureController.instance.selectedFixture.value;
    }
    if (Get.isRegistered<MatchCaptureController>()) {
      return MatchCaptureController.instance.fixture.value;
    }
    return null;
  }

  Future<void> refresh() async {
    if (isRefreshing.value) return;

    isRefreshing.value = true;
    isLoading.value = true;
    try {
      // Load stats first so the list appears without waiting on fixture refresh.
      await loadStats();
      await _refreshFixtureDetails();
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> _refreshFixtureDetails() async {
    final fixtureId = fixture?.id;
    if (fixtureId == null) return;

    if (Get.isRegistered<AgentFixtureController>()) {
      final agentCtrl = AgentFixtureController.instance;
      await agentCtrl.getAgentFixtures();
      for (final f in agentCtrl.fixtures) {
        if (f.id == fixtureId) {
          activeFixture.value = f;
          agentCtrl.selectedFixture.value = f;
          break;
        }
      }
    }

    if (Get.isRegistered<MatchCaptureController>()) {
      await MatchCaptureController.instance.getFixtureData();
      await MatchCaptureController.instance.getMatchScore();
    }
  }

  Future<void> loadStats() async {
    final fixtureId = fixture?.id;
    if (fixtureId == null) return;

    if (Get.isRegistered<MatchCaptureController>()) {
      final cached = MatchCaptureController.instance.fixtureData.value;
      if (cached != null && cached.isNotEmpty) {
        stats.assignAll(cached);
      }
    }

    final result = await matchDataUsecase.call(
      GetMatchDataParams(fixtureId: fixtureId.toString()),
    );

    result.fold((_) {}, stats.assignAll);
  }
}
