import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/fixtures/presentation/controllers/agent_fixture_controller.dart';
import 'package:tisini/features/match_capture/data/models/lineup_model.dart';
import 'package:tisini/features/match_capture/data/models/player_model.dart';
import 'package:tisini/features/match_capture/domain/entities/event_category.dart';
import 'package:tisini/features/match_capture/domain/entities/formation.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/entities/match_score.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/domain/usecases/event_category.dart';
import 'package:tisini/features/match_capture/domain/match_event_sync.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_metrics.dart';
import 'package:tisini/features/match_capture/domain/usecases/save_match_event_locally.dart';
import 'package:tisini/features/match_capture/domain/usecases/update_match_event_status.dart';
import 'package:tisini/features/match_capture/domain/usecases/team_lineup.dart';
import 'package:tisini/features/match_capture/domain/usecases/swap_players.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_scores.dart';
import 'package:tisini/features/match_capture/domain/usecases/team_players.dart';
import 'package:tisini/features/match_capture/presentation/controllers/timer_controller.dart';
import 'package:tisini/features/match_capture/presentation/pages/behaviour_screen.dart';
import 'package:tisini/features/match_capture/presentation/widgets/edit_player_sheet.dart';
import 'package:tisini/features/match_capture/presentation/widgets/match_recording_guard.dart';
import 'package:tisini/features/match_capture/presentation/widgets/player_capture_events.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_data.dart';
import 'package:tisini/shared/fixture_data/domain/usecases/get_fixture_data_usecase.dart';
import 'package:tisini/shared/fixture_data/domain/usecases/match_data_usecase.dart';

class MatchCaptureController extends GetxController
    with WidgetsBindingObserver {
  static MatchCaptureController get instance => Get.find();

  static const _rugby7FixtureType = 'rugby7';
  static const _lineupPollInterval = Duration(seconds: 15);

  TimerController get timerController => Get.find();

  bool get isHomeTeam => timerController.isHomeTeam.value;
  String get matchMinute => timerController.formattedTime.value.split(":")[0];
  String get matchSecond => timerController.formattedTime.value.split(":")[1];
  String get matchQuarter => timerController.quarter.value;
  String get matchHalf => timerController.half.value;
  Formation? get selectedFormation => timerController.selectedFormation.value;

  bool get canRecordEvents => timerController.canRecordEvents;

  MatchRecordingBlock get recordingBlock => timerController.recordingBlock;

  final Rx<AgentFixture?> fixture = Rx<AgentFixture?>(null);

  final MatchMetricsUsecase matchMetrics;
  final CreateMatchEventUsecase createMatchEvent;
  final GetFixtureDataUsecase getFixtureDataUsecase;
  final TeamLineupUsecase teamLineup;
  final SaveMatchEventLocally saveMatchEventLocally;
  final UpdateMatchEventStatus updateMatchEventStatus;
  final SwapPlayersUsecase swapPlayersUsecase;
  final MatchScoresUsecase matchScoresUsecase;
  final GetMatchDataUsecase matchDataUsecase;
  final GetMatchEventCategoriesUseCase getMatchEventCategories;
  final UpdateTeamPlayerUsecase updateTeamPlayerUsecase;

  MatchCaptureController({
    required this.matchMetrics,
    required this.createMatchEvent,
    required this.getFixtureDataUsecase,
    required this.teamLineup,
    required this.saveMatchEventLocally,
    required this.updateMatchEventStatus,
    required this.swapPlayersUsecase,
    required this.matchScoresUsecase,
    required this.matchDataUsecase,
    required this.getMatchEventCategories,
    required this.updateTeamPlayerUsecase,
  });

  final box = GetStorage();

  final RxList<MatchEventCategory> matchCategories = <MatchEventCategory>[].obs;

  /// Metrics with nested [Metric.details] / [Metric.subDetails] from `/metrics?with_details=true`.
  final RxList<Metric> metricsList = <Metric>[].obs;
  final RxList<Metric> teamEvents = <Metric>[].obs;
  final RxList<Lineup> homeLineup = <Lineup>[].obs;
  final RxList<Lineup> awayLineup = <Lineup>[].obs;

  final RxBool isLoadingEvents = false.obs;
  final RxBool isTeamCaptureView = false.obs;

  final RxInt homeScore = 0.obs;
  final RxInt awayScore = 0.obs;
  final Rx<MatchScore?> matchScore = Rx<MatchScore?>(null);
  final RxList<Lineup> starters = <Lineup>[].obs;
  final RxList<Lineup> subs = <Lineup>[].obs;
  final RxInt lineupRevision = 0.obs;
  final Rx<Metric?> selectedEvent = Rx<Metric?>(null);
  final Rx<Detail?> selectedSubEvent = Rx<Detail?>(null);
  final Rx<SubDetail?> selectedSubDetail = Rx<SubDetail?>(null);
  final RxList<Detail> filteredSubEvents = <Detail>[].obs;
  final RxString selectedTeam = ''.obs;
  final RxList<Map<String, dynamic>> submittedEvents =
      <Map<String, dynamic>>[].obs;
  final Rx<List<MatchData>?> fixtureData = Rx<List<MatchData>?>(null);
  final Rx<Lineup?> selectedSubPlayer = Rx<Lineup?>(null);
  final Rx<Lineup?> selectedStarterPlayer = Rx<Lineup?>(null);

  /// Two-tap reorder: swap [lineupposition] locally; API wired later via [buildUpdateLineupPayload].
  final RxBool isReorderMode = false.obs;
  final Rx<Lineup?> reorderSourcePlayer = Rx<Lineup?>(null);

  /// Set when opening [PlayerCaptureEventsScreen] after long-press; cleared when that route pops.
  /// Prevents losing the player between multiple submits on the same sheet (we used to clear
  /// [selectedStarterPlayer] after every submit).
  Lineup? _playerLockedForStatSheet;

  Timer? _lineupPollTimer;
  bool _isLineupPollInFlight = false;
  bool _isLineupMutationInFlight = false;
  bool _isAppInForeground = true;

  String? get pitchBgImage {
    switch (fixture.value?.fixtureType) {
      case 'rugby15':
        return 'assets/images/rugby.jpeg';
      case 'rugby7':
        return 'assets/images/rugby.jpeg';
      case 'rugby10':
        return 'assets/images/rugby.jpeg';
      case 'football':
        return 'assets/images/football.jpeg';
      case 'basketball':
        return 'assets/images/basketball.jpeg';
      case 'hockey':
        return 'assets/images/hockey.jpg';
      case 'handball':
        return 'assets/images/handball.jpeg';
      default:
        return 'assets/images/court.png';
    }
  }

  bool get _isRugby7Fixture =>
      (fixture.value?.fixtureType ?? '') == _rugby7FixtureType;

  bool get _canPollLineups =>
      _isRugby7Fixture &&
      _isAppInForeground &&
      !isLoadingEvents.value &&
      !isReorderMode.value &&
      reorderSourcePlayer.value == null &&
      !_isLineupMutationInFlight &&
      !_isLineupPollInFlight;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Support both: arguments: fixture and arguments: {'fixture': fixture}
    final args = Get.arguments;
    if (args is AgentFixture) {
      fixture.value = args;
    } else if (args is Map && args['fixture'] is AgentFixture) {
      fixture.value = args['fixture'] as AgentFixture;
    } else {
      fixture.value = null;
    }

    loadEventsAndLineups().whenComplete(_startLineupPollingIfNeeded);
    getMatchCategories();
    getFixtureData();
    getMatchScore();
  }

  @override
  void onClose() {
    _stopLineupPolling();
    WidgetsBinding.instance.removeObserver(this);
    // Refresh fixture-options counts when leaving capture (back button, etc.).
    if (Get.isRegistered<AgentFixtureController>()) {
      Get.find<AgentFixtureController>().loadFixtureEvents();
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        _startLineupPollingIfNeeded();
        if (_canPollLineups) {
          unawaited(_pollLineups());
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _isAppInForeground = false;
        _stopLineupPolling();
    }
  }

  void _startLineupPollingIfNeeded() {
    if (!_isRugby7Fixture || _lineupPollTimer != null) return;

    _lineupPollTimer = Timer.periodic(_lineupPollInterval, (_) {
      unawaited(_pollLineups());
    });
  }

  void _stopLineupPolling() {
    _lineupPollTimer?.cancel();
    _lineupPollTimer = null;
  }

  Future<void> _pollLineups() async {
    if (!_canPollLineups) return;

    _isLineupPollInFlight = true;
    try {
      await refreshLineups(silent: true);
    } finally {
      _isLineupPollInFlight = false;
    }
  }

  String _lineupFingerprint(Lineup player) {
    return [
      player.player.id,
      player.role,
      player.lineupPosition,
      player.jerseyNumber,
      player.isGoalkeeper,
      player.teamPlayer,
      player.isSentOff,
    ].join('|');
  }

  bool _sameLineup(List<Lineup> current, List<Lineup> next) {
    if (current.length != next.length) return false;
    final currentKeys = current.map(_lineupFingerprint).toSet();
    final nextKeys = next.map(_lineupFingerprint).toSet();
    return currentKeys.length == nextKeys.length &&
        currentKeys.containsAll(nextKeys);
  }

  Future<void> getMatchCategories() async {
    final fixtureType = fixture.value?.fixtureType ?? '';

    final response = await getMatchEventCategories.call(
      GetMatchEventCategoriesParams(fixtureType: fixtureType),
    );

    response.fold(
      (failure) {
        debugPrint('Error getting match categories: ${failure.message}');
        matchCategories.clear();
      },
      (success) {
        final sorted = [...success]
          ..sort((a, b) => a.ranker.compareTo(b.ranker));
        matchCategories.assignAll(sorted);
      },
    );
  }

  Future<String?> getToken() async {
    return box.read('token') as String?;
  }

  /// Category IDs for behaviour traits — excluded from the main events grid
  /// and shown on the dedicated Behaviour screen instead.
  static const _behaviourCategoryIds = {22, 23};

  List<Metric> get behaviourMetrics => metricsList
      .where((e) => _behaviourCategoryIds.contains(e.metricCategory))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  void getTeamEvents() {
    if (isTeamCaptureView.value) {
      final events = metricsList
          .where(
            (e) =>
                e.isTeam == 1 &&
                !_behaviourCategoryIds.contains(e.metricCategory),
          )
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      teamEvents.assignAll(events);
    } else {
      const excludeEvents = {17, 39, 52, 110, 226, 252};
      teamEvents.assignAll(
        metricsList.where(
          (e) =>
              !excludeEvents.contains(e.id) &&
              !_behaviourCategoryIds.contains(e.metricCategory),
        ),
      );
    }
  }

  /// Decides team vs player capture: team capture when both lineups are empty.
  void getCaptureView() {
    final homePlayers = homeLineup.length;
    final awayPlayers = awayLineup.length;

    if (homePlayers <= 0 && awayPlayers <= 0) {
      isTeamCaptureView.value = true;
    } else {
      isTeamCaptureView.value = false;
    }
  }

  void getStartersAndSubs({required bool isHomeTeam}) {
    final players = isHomeTeam ? homeLineup : awayLineup;

    final starters = players.where((p) => p.role == "first11").toList();
    final subs = players
        .where((p) => p.role == "sub" || p.role == "subs")
        .toList();

    final sortedStarters = List<Lineup>.from(starters);
    sortedStarters.sort((a, b) {
      final posA = int.tryParse(a.lineupPosition.toString()) ?? 999;
      final posB = int.tryParse(b.lineupPosition.toString()) ?? 999;
      return posA.compareTo(posB);
    });

    this.starters.assignAll(sortedStarters);
    this.subs.assignAll(subs);
  }

  /// Rebuilds [starters]/[subs] for the active side and notifies player capture UI.
  void _syncLineupPresentation() {
    getStartersAndSubs(isHomeTeam: isHomeTeam);
    lineupRevision.value++;
  }

  Lineup _cloneLineup(
    Lineup lineup, {
    String? role,
    int? lineupPosition,
    bool? isGoalkeeper,
  }) {
    return LineupModel.fromEntity(lineup).copyWith(
      role: role,
      lineupPosition: lineupPosition,
      isGoalkeeper: isGoalkeeper,
    );
  }

  void _replaceTeamLineup(bool isHomeTeam, List<Lineup> updated) {
    final list = isHomeTeam ? homeLineup : awayLineup;
    list.assignAll(_uniqueLineupById(updated));
    _syncLineupPresentation();
  }

  /// Swaps a starter off for a sub on the pitch (optimistic / offline).
  void _applyLocalSubstitution({
    required bool isHomeTeam,
    required Lineup starter,
    required Lineup sub,
  }) {
    final starterId = starter.player.id.toString().trim();
    final subId = sub.player.id.toString().trim();
    if (starterId.isEmpty || subId.isEmpty) return;

    final pitchPosition = starter.lineupPosition;
    final starterWasGk = starter.isGoalkeeper;

    final updated = (isHomeTeam ? homeLineup : awayLineup).map((p) {
      final pid = p.player.id.toString().trim();
      if (pid == starterId) {
        return _cloneLineup(
          p,
          role: 'sub',
          lineupPosition: TeamPlayerModel.substituteLineupPosition,
          isGoalkeeper: false,
        );
      }
      if (pid == subId) {
        return _cloneLineup(
          p,
          role: 'first11',
          lineupPosition: pitchPosition,
          isGoalkeeper: starterWasGk,
        );
      }
      return p;
    }).toList();

    _replaceTeamLineup(isHomeTeam, updated);
  }

  /// Swaps pitch positions between two starters (optimistic / offline).
  void _applyLocalPositionSwap({
    required bool isHomeTeam,
    required Lineup first,
    required Lineup second,
  }) {
    final firstId = first.player.id.toString().trim();
    final secondId = second.player.id.toString().trim();
    if (firstId.isEmpty || secondId.isEmpty) return;

    final posA = first.lineupPosition;
    final posB = second.lineupPosition;

    final updated = (isHomeTeam ? homeLineup : awayLineup).map((p) {
      final pid = p.player.id.toString().trim();
      if (pid == firstId) return _cloneLineup(p, lineupPosition: posB);
      if (pid == secondId) return _cloneLineup(p, lineupPosition: posA);
      return p;
    }).toList();

    _replaceTeamLineup(isHomeTeam, updated);
  }

  // Selection methods
  void selectEvent(Metric? event) {
    selectedEvent.value = event;
    selectedSubEvent.value = null;
    selectedSubDetail.value = null;

    if (event == null) {
      filteredSubEvents.clear();
    } else {
      // Nested metric details replace the old flat /metric-details list.
      filteredSubEvents.assignAll(event.details);
    }
  }

  void selectSubEvent(Detail? subEvent) {
    if (selectedEvent.value == null) {
      throw StateError('Cannot select detail without selecting metric first');
    }
    selectedSubEvent.value = subEvent;
    selectedSubDetail.value = null;
  }

  void selectSubDetail(SubDetail? subDetail) {
    if (selectedEvent.value == null) {
      throw StateError(
        'Cannot select sub-detail without selecting metric first',
      );
    }
    selectedSubDetail.value = subDetail;
  }

  bool get needsDetailPicker => filteredSubEvents.isNotEmpty;

  /// Show sub-detail sheet only when the selected detail opts in
  /// ([Detail.needsSubDetails]) and the metric actually has sub-details.
  bool get needsSubDetailPicker {
    final detail = selectedSubEvent.value;
    final hasSubDetails = selectedEvent.value?.subDetails.isNotEmpty ?? false;
    return hasSubDetails && (detail?.needsSubDetails ?? false);
  }

  void selectSubPlayer(Lineup? player) {
    selectedSubPlayer.value = player;
  }

  void selectStarterPlayer(Lineup? player) {
    selectedStarterPlayer.value = player;
  }

  void setSubstitutionEvent() {
    final fixtureType = fixture.value?.fixtureType ?? '';
    final substitutionId = switch (fixtureType) {
      'football' => 17,
      'rugby7' || 'rugby15' || 'rugby10' => 252,
      'basketball' => 226,
      _ => null,
    };

    if (substitutionId == null) {
      selectedEvent.value = null;
      return;
    }

    selectedEvent.value = metricsList.firstWhereOrNull(
      (event) => event.id == substitutionId,
    );
  }

  void openEventsScreen({
    required BuildContext context,
    required bool isHomeTeam,
    required Lineup player,
  }) async {
    if (!await ensureMatchRecordingAllowed(context: context)) return;

    selectStarterPlayer(player);
    _playerLockedForStatSheet = player;
    Get.to(
      () => const PlayerCaptureEventsScreen(),
      fullscreenDialog: true,
    )?.whenComplete(_clearStatSheetPlayerLock);
  }

  void openBehaviourForm({
    required BuildContext context,
    required bool isHomeTeam,
    required Lineup player,
    bool bypassGuard = false,
  }) async {
    if (!bypassGuard &&
        !await ensureMatchRecordingAllowed(context: context)) return;

    selectStarterPlayer(player);
    _playerLockedForStatSheet = player;
    Get.to(
      () => BehaviourScreen(bypassGuard: bypassGuard),
      fullscreenDialog: true,
    )?.whenComplete(_clearStatSheetPlayerLock);
  }

  /// Submits one event per entry in [selections] (metricId -> chosen Detail).
  /// Skips metrics where no detail was chosen (null value).
  /// Pass [bypassGuard] = true to skip the match-start check (retrospective entry).
  Future<void> submitBehaviourForm({
    required bool isHomeTeam,
    required Map<int, Detail?> selections,
    bool bypassGuard = false,
  }) async {
    final player = _lineupForSubmit();
    final teamName =
        isHomeTeam ? fixture.value?.team1Name : fixture.value?.team2Name;

    var submitted = 0;
    for (final entry in selections.entries) {
      final detail = entry.value;
      if (detail == null) continue;

      final metric = metricsList.firstWhereOrNull((m) => m.id == entry.key);
      if (metric == null) continue;

      final pName = player != null ? player.player.name : teamName;
      final narration = '${metric.name} — ${detail.name} by $pName';

      await _submitMatchEvent(
        isHomeTeam: isHomeTeam,
        submission: _MatchEventSubmission(
          addOwnGoal: false,
          metricId: metric.id,
          metricDetailId: int.tryParse(detail.id) ?? 0,
          playerId:
              int.tryParse(player?.player.id.toString() ?? '') ?? 0,
          narration: narration,
          snackbarTitle: '${metric.name} — ${detail.name}',
          successBody: (msg) => msg,
          successDuration: 1,
          snackPosition: SnackPosition.TOP,
        ),
      );
      submitted++;
    }

    if (submitted > 0) {
      showSnackbar(
        'Behaviour saved',
        '$submitted behaviour trait${submitted == 1 ? '' : 's'} recorded.',
        Colors.green,
        position: SnackPosition.TOP,
      );
    }
  }

  void _clearStatSheetPlayerLock() {
    _playerLockedForStatSheet = null;
    selectedStarterPlayer.value = null;
  }

  /// Prefer lock from stat sheet, then Rx; re-resolve by [Lineup.playerId] after lineup refresh.
  Lineup? get playerForStatSheet => _lineupForSubmit();

  Lineup? _lineupForSubmit() {
    final pinned = _playerLockedForStatSheet ?? selectedStarterPlayer.value;
    if (pinned == null) return null;
    final pid = pinned.player.id.toString().trim();
    if (pid.isEmpty) return pinned;
    for (final p in homeLineup) {
      if (p.player.id.toString().trim() == pid) return p;
    }
    for (final p in awayLineup) {
      if (p.player.id.toString().trim() == pid) return p;
    }
    return pinned;
  }

  /// Updates player name / position / jersey via API, then patches live lineup lists.
  /// Returns `true` when the API update succeeds.
  Future<bool> updateCapturedPlayer(
    Lineup player,
    SavedLineupPlayerEdit edit,
  ) async {
    final result = await updateTeamPlayerUsecase.call(
      UpdateTeamPlayerParams(
        teamId: player.team.toString(),
        playerId: player.teamPlayer.toString(),
        player: {
          'fname': edit.firstName,
          'sname': edit.lastName,
          'oname': edit.surname,
          'position': edit.position,
          'jersey': edit.jerseyNumber.toString(),
          'fixture_id': fixture.value?.id.toString() ?? '',
        },
      ),
    );

    return result.fold(
      (failure) {
        showSnackbar('Player update error', failure.message, Colors.red);
        return false;
      },
      (_) {
        final name = edit.fullName.isNotEmpty
            ? edit.fullName
            : player.player.name;
        final position = edit.position.isNotEmpty
            ? edit.position
            : player.player.currentPosition;

        final patched = LineupModel.fromEntity(player).copyWith(
          player: PlayerModel.fromEntity(
            player.player,
          ).copyWith(name: name, currentPosition: position),
          jerseyNumber: edit.jerseyNumber,
        );

        _patchPlayerInLineups(patched);
        _playerLockedForStatSheet = patched;
        if (selectedStarterPlayer.value?.id == player.id ||
            selectedStarterPlayer.value?.player.id == player.player.id) {
          selectedStarterPlayer.value = patched;
        }
        if (selectedSubPlayer.value?.id == player.id ||
            selectedSubPlayer.value?.player.id == player.player.id) {
          selectedSubPlayer.value = patched;
        }
        _syncLineupPresentation();

        showSnackbar(
          'Player updated',
          '$name · #${edit.jerseyNumber}',
          Colors.green,
        );
        return true;
      },
    );
  }

  void _patchPlayerInLineups(Lineup patched) {
    final pid = patched.player.id.toString().trim();
    final lineupId = patched.id;

    void patchList(RxList<Lineup> list) {
      final index = list.indexWhere(
        (p) =>
            p.id == lineupId ||
            (pid.isNotEmpty && p.player.id.toString().trim() == pid),
      );
      if (index >= 0) {
        list[index] = patched;
        list.refresh();
      }
    }

    patchList(homeLineup);
    patchList(awayLineup);
  }

  void goToLineupSelectorScreen({required bool isHomeTeam}) {
    Get.toNamed('/lineup-selector');
  }

  List<Lineup> _uniqueLineupById(List<Lineup> players) {
    final byId = <String, Lineup>{};
    for (final player in players) {
      if (player.player.id.toString().isEmpty) continue;
      byId[player.player.id.toString()] = player;
    }
    return byId.values.toList();
  }

  /// Fetches metrics (with nested details) and both team lineups on load.
  Future<void> loadEventsAndLineups() async {
    isLoadingEvents.value = true;
    final token = await getToken();
    final fixtureType = fixture.value?.fixtureType ?? '';

    if (token == null || token.isEmpty || fixtureType.isEmpty) {
      isLoadingEvents.value = false;
      return;
    }

    final params = MatchMetricsParams(fixtureType: fixtureType);

    try {
      final results = await Future.wait([
        matchMetrics.call(params),
        teamLineup.call(
          TeamLineupParams(
            token: token,
            fixtureId: fixture.value?.id.toString() ?? '',
            teamId: fixture.value?.team1Id.toString() ?? '',
          ),
        ),
        teamLineup.call(
          TeamLineupParams(
            token: token,
            fixtureId: fixture.value?.id.toString() ?? '',
            teamId: fixture.value?.team2Id.toString() ?? '',
          ),
        ),
      ]);

      results[0].fold(
        (failure) {
          metricsList.clear();
          showSnackbar('Events', failure.message, Colors.red);
        },
        (list) {
          metricsList.assignAll(list as List<Metric>);
          getTeamEvents();
        },
      );

      results[1].fold(
        (failure) {
          showSnackbar('Team lineup', failure.message, Colors.red);
        },
        (list) {
          homeLineup.assignAll(
            _uniqueLineupById(List<Lineup>.from(list as List)),
          );
        },
      );

      results[2].fold(
        (failure) {
          showSnackbar('Team lineup', failure.message, Colors.red);
        },
        (list) {
          awayLineup.assignAll(
            _uniqueLineupById(List<Lineup>.from(list as List)),
          );
        },
      );

      getCaptureView();
      getTeamEvents();
      _syncLineupPresentation();
    } finally {
      isLoadingEvents.value = false;
    }
  }

  /// Refreshes only lineups (no loading indicator). Use after substitution etc.
  /// When [silent] is true (polling), failures are logged only and unchanged
  /// lineups are not reassigned.
  Future<void> refreshLineups({bool silent = false}) async {
    final token = await getToken();
    final fixtureId = fixture.value?.id.toString() ?? '';
    final homeId = fixture.value?.team1Id.toString() ?? '';
    final awayId = fixture.value?.team2Id.toString() ?? '';

    if (token == null || token.isEmpty || fixtureId.isEmpty) return;

    try {
      final results = await Future.wait([
        teamLineup.call(
          TeamLineupParams(token: token, fixtureId: fixtureId, teamId: homeId),
        ),
        teamLineup.call(
          TeamLineupParams(token: token, fixtureId: fixtureId, teamId: awayId),
        ),
      ]);

      var changed = false;

      results[0].fold(
        (failure) {
          if (silent) {
            debugPrint('Lineup poll (home): ${failure.message}');
          } else {
            showSnackbar('Lineup', failure.message, Colors.red);
          }
        },
        (list) {
          final next = _uniqueLineupById(List<Lineup>.from(list as List));
          if (!_sameLineup(homeLineup, next)) {
            homeLineup.assignAll(next);
            changed = true;
          }
        },
      );
      results[1].fold(
        (failure) {
          if (silent) {
            debugPrint('Lineup poll (away): ${failure.message}');
          } else {
            showSnackbar('Lineup', failure.message, Colors.red);
          }
        },
        (list) {
          final next = _uniqueLineupById(List<Lineup>.from(list as List));
          if (!_sameLineup(awayLineup, next)) {
            awayLineup.assignAll(next);
            changed = true;
          }
        },
      );

      if (changed) {
        getCaptureView();
        getTeamEvents();
        _syncLineupPresentation();
      }
    } catch (e) {
      debugPrint('Error refreshing lineups: $e');
    }
  }

  Future<void> getFixtureData() async {
    final response = await matchDataUsecase.call(
      GetMatchDataParams(fixtureId: fixture.value?.id.toString() ?? ''),
    );

    response.fold(
      (failure) {
        debugPrint('Error getting fixture data: ${failure.message}');
      },
      (success) {
        fixtureData.value = success;
      },
    );
  }

  Future<void> getMatchScore() async {
    final response = await matchScoresUsecase.call(
      MatchScoresParams(fixtureId: fixture.value?.id.toString() ?? ''),
    );

    response.fold(
      (failure) {
        debugPrint("Error getting match score: $failure");
      },
      (success) {
        matchScore.value = MatchScore(home: success.home, away: success.away);
      },
    );
  }

  void toggleReorderMode() {
    if (isReorderMode.value) {
      cancelReorderMode();
      return;
    }
    isReorderMode.value = true;
    reorderSourcePlayer.value = null;
    selectedSubPlayer.value = null;
    selectedStarterPlayer.value = null;
    selectedEvent.value = null;
    selectedSubEvent.value = null;
    selectedSubDetail.value = null;
  }

  void cancelReorderMode() {
    isReorderMode.value = false;
    reorderSourcePlayer.value = null;
  }

  bool isReorderSource(Lineup player) {
    final source = reorderSourcePlayer.value;
    if (source == null) return false;
    return source.player.id.toString().trim() ==
        player.player.id.toString().trim();
  }

  void onReorderPlayerTap(Lineup player, {required bool isHomeTeam}) async {
    if (player.role != 'first11') {
      showSnackbar(
        '',
        'Only starters can be reordered',
        Colors.orange,
        position: SnackPosition.TOP,
      );
      return;
    }

    final source = reorderSourcePlayer.value;
    if (source == null) {
      reorderSourcePlayer.value = player;
      return;
    }

    if (source.player.id.toString().trim() ==
        player.player.id.toString().trim()) {
      reorderSourcePlayer.value = null;
      return;
    }

    final swapPlayers = _swapPlayersPayload(source, player);

    _isLineupMutationInFlight = true;
    late final Either<Failure, List<Lineup>> response;
    try {
      response = await swapPlayersUsecase.call(
        SwapPlayersParams(
          teamId: player.team.toString(),
          fixtureId: fixture.value?.id.toString() ?? '',
          players: swapPlayers,
        ),
      );
    } finally {
      _isLineupMutationInFlight = false;
    }

    response.fold(
      (failure) {
        _applyLocalPositionSwap(
          isHomeTeam: isHomeTeam,
          first: source,
          second: player,
        );
        reorderSourcePlayer.value = null;
        isReorderMode.value = false;
        showSnackbar(
          'Swap players',
          'Saved locally — positions updated on pitch',
          Colors.orange,
          position: SnackPosition.TOP,
        );
      },
      (data) {
        if (isHomeTeam) {
          homeLineup.assignAll(data);
        } else {
          awayLineup.assignAll(data);
        }

        getStartersAndSubs(isHomeTeam: isHomeTeam);

        reorderSourcePlayer.value = null;
        isReorderMode.value = false;

        showSnackbar(
          'Swap players',
          'Players swapped successfully',
          Colors.green,
        );
      },
    );
  }

  List<Map<String, int>> _swapPlayersPayload(Lineup first, Lineup second) {
    return [
      {
        'player_id': int.tryParse(first.player.id.toString()) ?? 0,
        'lineupposition': int.tryParse(second.lineupPosition.toString()) ?? 0,
      },
      {
        'player_id': int.tryParse(second.player.id.toString()) ?? 0,
        'lineupposition': int.tryParse(first.lineupPosition.toString()) ?? 0,
      },
    ];
  }

  static const _substitutionEventIds = {'17', '39', '52', '110', '226', '252'};

  /// Linked auto-event rules: when a primary metric + specific detail (subevent)
  /// + sub-detail combination is submitted, a secondary event is automatically fired.
  ///
  /// Structure: metricId → detailId → subDetailId → (linkedMetricId, linkedDetailId)
  ///
  /// e.g. Penalty Gain (261) + detail Scrum (698) + sub-detail Won (57)
  ///       → auto-fire Scrum (262) with detail Won (702)
  static const _linkedEventRules =
      <int, Map<String, Map<String, (int metricId, int detailId)>>>{
    261: {
      '698': {              // detail = Scrum
        '57': (262, 702),   // sub-detail Won    → Scrum Won
        '58': (262, 703),   // sub-detail Lost   → Scrum Lost
        '59': (262, 704),   // sub-detail Stolen → Scrum Stolen
      },
    },
  };

  static const _scoreRefreshEventIds = {
    '19',
    '49',
    '232',
    "253",
    '169',
    '79',
    '33',
  };

  void submitOwnGoal({required bool isHomeTeam, BuildContext? context}) async {
    if ((fixture.value?.fixtureType ?? '') != 'football') return;
    if (!await ensureMatchRecordingAllowed(context: context)) return;

    await _submitMatchEvent(
      isHomeTeam: isHomeTeam,
      submission: _MatchEventSubmission(
        addOwnGoal: true,
        metricId: 19,
        narration: '',
        snackbarTitle: 'Own Goal',
        successBody: (_) => 'Own goal added successfully',
        onUploadSuccess: (_) async => getMatchScore(),
      ),
    );
  }

  void submitMetric({required bool isHomeTeam, BuildContext? context}) async {
    if (!await ensureMatchRecordingAllowed(context: context)) return;

    final event = selectedEvent.value;
    if (event == null) return;

    final penaltyTryIds = ['639', '771'];

    try {
      final subevent = selectedSubEvent.value;
      final subDetail = selectedSubDetail.value;
      final subplayer = selectedSubPlayer.value;
      final player = penaltyTryIds.contains(subevent?.id)
          ? null
          : _lineupForSubmit();
      final teamName = isHomeTeam
          ? fixture.value?.team1Name
          : fixture.value?.team2Name;
      final isSubstitution = _substitutionEventIds.contains(
        event.id.toString(),
      );
      final pName = player != null ? player.player.name : teamName;
      final narration = isSubstitution
          ? 'Substitute For $teamName'
          : '${event.name} by $pName';
      final detailLabel = [
        if (subevent?.name != null) subevent!.name,
        if (subDetail?.name != null) subDetail!.name,
      ].join(' - ');
      final snackbarTitle = detailLabel.isEmpty
          ? event.name
          : '${event.name} - $detailLabel';

      if (isSubstitution && (player == null || subplayer == null)) {
        showSnackbar(
          'Substitution',
          'Select a starter and a substitute',
          Colors.orange,
          position: SnackPosition.TOP,
        );
        return;
      }

      await _submitMatchEvent(
        isHomeTeam: isHomeTeam,
        submission: _MatchEventSubmission(
          addOwnGoal: false,
          metricId: event.id,
          metricDetailId: int.tryParse(subevent?.id ?? '') ?? 0,
          metricSubDetailId: int.tryParse(subDetail?.id ?? '') ?? 0,
          playerId: int.tryParse(player?.player.id.toString() ?? '') ?? 0,
          subplayerId: int.tryParse(subplayer?.player.id.toString() ?? '') ?? 0,
          narration: narration,
          snackbarTitle: snackbarTitle,
          substitutionStarter: isSubstitution ? player : null,
          substitutionSub: isSubstitution ? subplayer : null,
          successBody: (message) => message,
          successDuration: 1,
          snackPosition: SnackPosition.TOP,
          onAfterLocalSave: isSubstitution
              ? () async {
                  showSnackbar(
                    '',
                    'Subbing player',
                    Colors.green,
                    position: SnackPosition.TOP,
                  );
                }
              : null,
          onUploadSuccess: (_) async {
            if (_scoreRefreshEventIds.contains(event.id.toString())) {
              getFixtureData();
              getMatchScore();
            }
            if (isSubstitution) {
              unawaited(refreshLineups());
            }
          },
        ),
      );

      // Fire any linked auto-event defined by the rule table.
      await _submitLinkedEvent(
        primaryMetricId: event.id,
        detailId: subevent?.id,
        subDetailId: subDetail?.id,
        isHomeTeam: isHomeTeam,
        player: player,
        teamName: teamName,
      );
    } catch (e) {
      debugPrint('Error submitting event: $e');
      showSnackbar(
        'Error',
        'Failed to add event',
        Colors.red,
        position: SnackPosition.TOP,
      );
    }
  }

  /// Checks [_linkedEventRules] and, if a rule matches, silently submits the
  /// linked secondary event. No snackbar is shown — the primary event's
  /// feedback is sufficient.
  Future<void> _submitLinkedEvent({
    required int primaryMetricId,
    required String? detailId,
    required String? subDetailId,
    required bool isHomeTeam,
    required Lineup? player,
    required String? teamName,
  }) async {
    if (detailId == null || subDetailId == null) return;
    final byDetail = _linkedEventRules[primaryMetricId];
    if (byDetail == null) return;
    final rules = byDetail[detailId];
    if (rules == null) return;
    final rule = rules[subDetailId];
    if (rule == null) return;

    final (linkedMetricId, linkedDetailId) = rule;
    final linkedMetric = metricsList.firstWhereOrNull(
      (m) => m.id == linkedMetricId,
    );
    final pName = player != null ? player.player.name : teamName;
    final linkedDetailName = linkedMetric?.details
        .firstWhereOrNull((d) => int.tryParse(d.id) == linkedDetailId)
        ?.name;
    final narration = linkedDetailName != null
        ? '${linkedMetric?.name ?? 'Auto'} — $linkedDetailName by $pName'
        : '${linkedMetric?.name ?? 'Auto'} by $pName';

    await _submitMatchEvent(
      isHomeTeam: isHomeTeam,
      submission: _MatchEventSubmission(
        addOwnGoal: false,
        metricId: linkedMetricId,
        metricDetailId: linkedDetailId,
        playerId: int.tryParse(player?.player.id.toString() ?? '') ?? 0,
        narration: narration,
        snackbarTitle: linkedMetric?.name ?? 'Auto event',
        successBody: (msg) => msg,
        successDuration: 1,
        snackPosition: SnackPosition.TOP,
      ),
    );
  }

  Future<void> _submitMatchEvent({
    required bool isHomeTeam,
    required _MatchEventSubmission submission,
  }) async {
    final fixtureId = fixture.value?.id.toString() ?? '';
    if (fixtureId.isEmpty) {
      showSnackbar('Error', 'No fixture selected', Colors.red);
      return;
    }

    final teamId = isHomeTeam
        ? fixture.value?.team1Id.toString() ?? '0'
        : fixture.value?.team2Id.toString() ?? '0';

    final localId = 'evt_${teamId}_${DateTime.now().millisecondsSinceEpoch}';
    final appTimelog = DateTime.now().toUtc().toIso8601String();
    final payload = MatchEventSync.buildPayload(
      metricId: submission.metricId,
      metricDetailId: submission.metricDetailId,
      metricSubDetailId: submission.metricSubDetailId,
      playerId: submission.playerId,
      subplayerId: submission.subplayerId,
      teamId: int.tryParse(teamId) ?? 0,
      minute: int.tryParse(matchMinute) ?? 0,
      second: int.tryParse(matchSecond) ?? 0,
      moment: matchHalf,
      quarter: matchQuarter,
      narration: submission.narration,
      localId: localId,
      appTimelog: appTimelog,
    );

    final saved = await saveMatchEventLocally(
      SaveMatchEventLocallyParams(
        fixtureId: fixtureId,
        event: {
          ...payload,
          'local_id': localId,
          'status': 'pending',
          'uploaded': false,
          'add_own_goal': submission.addOwnGoal,
        },
      ),
    );

    await saved.fold(
      (failure) async {
        showSnackbar('Error', failure.message, Colors.red);
      },
      (savedEvent) async {
        submittedEvents.add(savedEvent);

        if (submission.substitutionStarter != null &&
            submission.substitutionSub != null) {
          _applyLocalSubstitution(
            isHomeTeam: isHomeTeam,
            starter: submission.substitutionStarter!,
            sub: submission.substitutionSub!,
          );
        }

        _clearEventSelection();

        await submission.onAfterLocalSave?.call();

        final response = await createMatchEvent.call(
          CreateMatchEventParams(
            fixtureId: fixtureId,
            matchEvent: _eventPayloadForUpload(savedEvent),
            addOwnGoal: submission.addOwnGoal,
          ),
        );

        await response.fold(
          (failure) async {
            await _persistMatchEventUploadStatus(
              fixtureId: fixtureId,
              localId: localId,
              status: 'failed',
            );
            showSnackbar(
              submission.snackbarTitle,
              'Failed to upload event. Saved locally and will be retried later.',
              Colors.orange,
              position: submission.snackPosition ?? SnackPosition.TOP,
              duration: 2,
            );
          },
          (success) async {
            await _persistMatchEventUploadStatus(
              fixtureId: fixtureId,
              localId: localId,
              status: 'success',
            );

            await submission.onUploadSuccess?.call(success);

            showSnackbar(
              submission.snackbarTitle,
              submission.successBody(success),
              Colors.green,
              duration: submission.successDuration ?? 2,
              position: submission.snackPosition ?? SnackPosition.TOP,
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _eventPayloadForUpload(Map<String, dynamic> record) {
    return MatchEventSync.payloadForUpload(record);
  }

  void _clearEventSelection() {
    selectedEvent.value = null;
    selectedSubEvent.value = null;
    selectedSubDetail.value = null;
    selectedSubPlayer.value = null;
    if (_playerLockedForStatSheet == null) {
      selectedStarterPlayer.value = null;
    }
  }

  Future<void> _persistMatchEventUploadStatus({
    required String fixtureId,
    required String localId,
    required String status,
  }) async {
    if (localId.isEmpty) return;

    final updated = await updateMatchEventStatus(
      UpdateMatchEventStatusParams(
        fixtureId: fixtureId,
        localId: localId,
        status: status,
      ),
    );

    updated.fold(
      (failure) =>
          debugPrint('Failed to update match event status: ${failure.message}'),
      (record) {
        final index = submittedEvents.indexWhere(
          (event) => event['local_id']?.toString() == localId,
        );
        if (index >= 0) {
          submittedEvents[index] = record;
        }
      },
    );
  }
}

class _MatchEventSubmission {
  const _MatchEventSubmission({
    required this.addOwnGoal,
    required this.metricId,
    this.metricDetailId = 0,
    this.metricSubDetailId = 0,
    this.playerId = 0,
    this.subplayerId = 0,
    this.narration = '',
    this.substitutionStarter,
    this.substitutionSub,
    required this.snackbarTitle,
    required this.successBody,
    this.successDuration,
    this.snackPosition,
    this.onAfterLocalSave,
    this.onUploadSuccess,
  });

  final bool addOwnGoal;
  final int metricId;
  final int metricDetailId;
  final int metricSubDetailId;
  final int playerId;
  final int subplayerId;
  final String narration;
  final Lineup? substitutionStarter;
  final Lineup? substitutionSub;
  final String snackbarTitle;
  final String Function(String apiMessage) successBody;
  final int? successDuration;
  final SnackPosition? snackPosition;
  final Future<void> Function()? onAfterLocalSave;
  final Future<void> Function(String apiMessage)? onUploadSuccess;
}
