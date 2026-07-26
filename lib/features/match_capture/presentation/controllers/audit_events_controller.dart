import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/entities/match_event.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/domain/match_event_sync.dart';
import 'package:tisini/features/match_capture/domain/usecases/get_submitted_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/save_submitted_events.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/widgets/edit_match_event_sheet.dart';

enum AuditEventsTab { lastTen, critical }

class AuditEventsController extends GetxController {
  static AuditEventsController get instance => Get.find();

  MatchCaptureController get matchCaptureController => Get.find();

  final MatchEventsUsecase matchEvents;
  final UpdateMatchEventUsecase updateMatchEvent;
  final DeleteMatchEventUsecase deleteMatchEvent;
  final GetSubmittedEventsUsecase getSubmittedEvents;
  final SaveSubmittedEventsUsecase saveSubmittedEvents;

  AuditEventsController({
    required this.matchEvents,
    required this.updateMatchEvent,
    required this.deleteMatchEvent,
    required this.getSubmittedEvents,
    required this.saveSubmittedEvents,
  });

  AgentFixture get fixture => matchCaptureController.fixture.value!;
  List<Metric> get fixtureMetrics => matchCaptureController.metricsList;
  List<Lineup> get homeLineup => matchCaptureController.homeLineup;
  List<Lineup> get awayLineup => matchCaptureController.awayLineup;

  final Rx<AuditEventsTab> selectedTab = AuditEventsTab.lastTen.obs;
  final RxList<MatchEvent> events = <MatchEvent>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatchEvents();
  }

  Future<void> selectTab(AuditEventsTab tab) async {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;
    await loadMatchEvents();
  }

  Future<void> loadMatchEvents() async {
    isLoading.value = true;
    errorMessage.value = '';
    events.clear();

    final isLastTen = selectedTab.value == AuditEventsTab.lastTen;
    final isCritical = selectedTab.value == AuditEventsTab.critical;

    final result = await matchEvents.call(
      MatchEventsParams(
        fixtureId: fixture.id.toString(),
        isLastTen: isLastTen,
        isCritical: isCritical,
      ),
    );

    result.fold(
      (failure) {
        events.clear();
        errorMessage.value = failure.message;
        showSnackbar('Audit Events', failure.message, Colors.red);
      },
      (list) {
        final sorted = [...list]
          ..sort((a, b) {
            final byMinute = b.minute.compareTo(a.minute);
            if (byMinute != 0) return byMinute;
            return b.second.compareTo(a.second);
          });
        events.assignAll(sorted);
      },
    );

    isLoading.value = false;
  }

  void onEditEvent(MatchEvent event) {
    final context = Get.context;
    if (context == null) return;

    showEditMatchEventSheet(
      context: context,
      event: event,
      metrics: fixtureMetrics,
      homeLineup: homeLineup,
      awayLineup: awayLineup,
      onSubmit: (draft) async {
        final payload = MatchEventSync.buildPayload(
          metricId: draft.metric.id,
          metricDetailId: int.tryParse(draft.metricDetail?.id ?? '') ?? 0,
          metricSubDetailId: int.tryParse(draft.metricSubDetail?.id ?? '') ?? 0,
          playerId: draft.player?.player.id ?? 0,
          subplayerId: draft.subplayer?.player.id ?? 0,
          teamId: event.team,
          minute: draft.minute,
          second: event.second,
          moment: draft.moment,
          quarter: event.quarter,
          narration: event.narration,
          localId: event.localid.isNotEmpty ? event.localid : 'evt_${event.id}',
          appTimelog: event.appTimelog,
          syncStatus: event.syncStatus,
        );

        final result = await updateMatchEvent.call(
          UpdateMatchEventParams(
            fixtureId: fixture.id.toString(),
            eventId: event.id.toString(),
            matchEvent: payload,
          ),
        );

        result.fold(
          (failure) {
            showSnackbar('Edit', failure.message, Colors.red);
          },
          (updated) async {
            final index = events.indexWhere((e) => e.id == updated.id);
            if (index >= 0) {
              events[index] = updated;
            } else {
              events.removeWhere((e) => e.id == event.id);
              events.add(updated);
            }

            await _syncLocalEventByLocalId(
              localId: payload['localid']?.toString() ?? event.localid,
              payload: payload,
            );

            showSnackbar(
              'Edit',
              '${updated.metric.name} updated',
              Colors.green,
              position: SnackPosition.TOP,
            );
          },
        );
      },
    );
  }

  /// Keeps the on-device copy in sync when this event was originally captured
  /// on this phone. No-op if [localId] is missing or not found locally.
  Future<void> _syncLocalEventByLocalId({
    required String localId,
    required Map<String, dynamic> payload,
  }) async {
    final id = localId.trim();
    if (id.isEmpty) return;

    final fixtureId = fixture.id.toString();
    final stored = await getSubmittedEvents.call(fixtureId);
    final index = stored.indexWhere(
      (e) => e['local_id']?.toString() == id || e['localid']?.toString() == id,
    );
    if (index < 0) return;

    final merged = <String, dynamic>{
      ...stored[index],
      ...payload,
      'local_id': id,
      'localid': id,
      'status': 'success',
      'uploaded': true,
      'uploaded_at': DateTime.now().toIso8601String(),
    };
    stored[index] = merged;
    await saveSubmittedEvents.call(fixtureId, stored);

    final memory = matchCaptureController.submittedEvents;
    final memIndex = memory.indexWhere(
      (e) => e['local_id']?.toString() == id || e['localid']?.toString() == id,
    );
    if (memIndex >= 0) {
      memory[memIndex] = merged;
    }
  }

  /// Deletes the event on the server and removes any matching local copy.
  Future<bool> deleteEvent(MatchEvent event) async {
    final result = await deleteMatchEvent.call(
      DeleteMatchEventParams(
        fixtureId: fixture.id.toString(),
        eventId: event.id.toString(),
      ),
    );

    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      showSnackbar('Delete', failure.message, Colors.red);
      return false;
    }

    final message = result.fold((_) => '', (m) => m);
    events.removeWhere((e) => e.id == event.id);
    await _removeLocalEventByLocalId(event.localid);
    showSnackbar(
      'Delete',
      message.isNotEmpty ? message : '${event.metric.name} deleted',
      Colors.green,
      position: SnackPosition.TOP,
    );
    return true;
  }

  Future<void> _removeLocalEventByLocalId(String localId) async {
    final id = localId.trim();
    if (id.isEmpty) return;

    final fixtureId = fixture.id.toString();
    final stored = await getSubmittedEvents.call(fixtureId);
    final next = stored
        .where(
          (e) =>
              e['local_id']?.toString() != id && e['localid']?.toString() != id,
        )
        .toList();

    if (next.length == stored.length) return;

    await saveSubmittedEvents.call(fixtureId, next);
    matchCaptureController.submittedEvents.removeWhere(
      (e) =>
          e['local_id']?.toString() == id || e['localid']?.toString() == id,
    );
  }
}
