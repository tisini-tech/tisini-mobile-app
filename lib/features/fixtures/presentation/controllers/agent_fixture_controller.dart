import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/fixtures/domain/usecases/agent_fixtures.dart';
import 'package:tisini/features/match_capture/domain/match_event_sync.dart';
import 'package:tisini/features/match_capture/domain/usecases/get_submitted_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/sync_events.dart';
import 'package:tisini/features/fixtures/presentation/bindings/team_stats_binding.dart';
import 'package:tisini/features/fixtures/presentation/pages/team_stats_screen.dart';

class AgentFixtureController extends GetxController {
  static AgentFixtureController get instance => Get.find();

  final AgentFixtures agentFixtures;
  final GetSubmittedEventsUsecase getSubmittedEventsUsecase;
  final SyncEventsUsecase syncEventsUsecase;

  AgentFixtureController({
    required this.agentFixtures,
    required this.getSubmittedEventsUsecase,
    required this.syncEventsUsecase,
  });

  final box = GetStorage();

  final isLoading = false.obs;
  final isSyncing = false.obs;

  RxList<AgentFixture> fixtures = RxList<AgentFixture>();
  final selectedFixture = Rx<AgentFixture?>(null);

  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  /// All locally saved match events for the selected fixture.
  final RxList<Map<String, dynamic>> localEvents =
      RxList<Map<String, dynamic>>([]);

  int get totalEvents => localEvents.length;

  int get syncedEvents =>
      localEvents.where(MatchEventSync.isSynced).length;

  int get pendingEvents =>
      localEvents.where(MatchEventSync.isPendingSync).length;

  bool get hasPendingSync => pendingEvents > 0;

  void setSearchQuery(String query) {
    searchQuery.value = query.trim();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  List<AgentFixture> get filteredFixtures {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return fixtures;

    return fixtures.where((fixture) {
      final pitch = fixture.pitchname?.toString().toLowerCase() ?? '';
      return fixture.team1Name.toLowerCase().contains(q) ||
          fixture.team2Name.toLowerCase().contains(q) ||
          fixture.matchtime.toLowerCase().contains(q) ||
          fixture.matchday.toLowerCase().contains(q) ||
          fixture.fixtureType.toLowerCase().contains(q) ||
          pitch.contains(q);
    }).toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    getAgentFixtures();
  }

  Future<String?> getToken() async {
    return box.read('token') as String?;
  }

  Future<void> getAgentFixtures() async {
    try {
      isLoading.value = true;

      final token = box.read('token') as String?;

      if (token == null || token.isEmpty) {
        showSnackbar('Error', 'Please log in to view fixtures.', Colors.red);
        return;
      }

      final result = await agentFixtures(AgentFixturesParams(token: token));

      result.fold(
        (failure) => showSnackbar('Error', failure.message, Colors.red),
        (success) => fixtures.value = success,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshFixtures() {
    getAgentFixtures();
  }

  void goToCollectionScreen() {
    // Get.to(() => const DataCollectionScreen());
  }

  void goToAwayPlayersScreen(String teamId) {
    // Get.to(() => const SelectStartersScreen());
  }

  void goToSelectLineupsScreen(Map<String, String> team) {
    final fixture = selectedFixture.value;
    Get.toNamed(
      '/lineup-selector',
      arguments: {'team': team, 'fixture': fixture},
    );
  }

  void applyRouteFixture(dynamic args) {
    if (args is! AgentFixture) return;
    selectedFixture.value = args;
    loadFixtureEvents();
  }

  void goToFixtureOptionsScreen(AgentFixture fixture) {
    selectedFixture.value = fixture;
    Get.toNamed('/fixture-options', arguments: fixture);
  }

  /// Loads submitted events for [selectedFixture] from local storage.
  Future<void> loadFixtureEvents() async {
    final fixtureId = selectedFixture.value?.id;
    if (fixtureId == null) {
      localEvents.clear();
      return;
    }
    final events = await getSubmittedEventsUsecase.call(fixtureId.toString());
    localEvents.assignAll(events);
  }

  Future<void> goToMatchCaptureScreen() async {
    final fixture = selectedFixture.value;
    if (fixture == null) return;

    await Get.toNamed('/match-capture', arguments: {'fixture': fixture});
    await loadFixtureEvents();
  }

  void goToFeedbackScreen() {
    final fixture = selectedFixture.value;
    if (fixture != null) {
      Get.toNamed('/feedback', arguments: {'fixture': fixture});
    }
  }

  void goToMatchOfficialsScreen() {
    Get.toNamed(
      '/match-officials',
      arguments: {'fixture': selectedFixture.value},
    );
  }

  void goToTeamStatsScreen() {
    Get.to(
      () => const TeamStatsScreen(),
      binding: TeamStatsBinding(),
      arguments: selectedFixture.value,
      fullscreenDialog: true,
    );
  }

  Future<void> syncEvents() async {
    final fixtureId = selectedFixture.value?.id;
    if (fixtureId == null) return;

    if (!hasPendingSync) {
      showSnackbar('Sync', 'All events are already synced', Colors.green);
      return;
    }

    isSyncing.value = true;
    try {
      final result = await syncEventsUsecase.call(
        SyncEventsParams(fixtureId: fixtureId.toString()),
      );

      result.fold(
        (failure) => showSnackbar('Sync failed', failure.message, Colors.red),
        (message) {
          showSnackbar('Sync', message, Colors.green);
          loadFixtureEvents();
        },
      );
    } finally {
      isSyncing.value = false;
    }
  }
}
