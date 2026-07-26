import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/core/constants/formations.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/match_capture/domain/entities/formation.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_events.dart';
import 'package:tisini/features/match_capture/domain/usecases/start_end_match.dart';
import 'package:tisini/features/match_capture/presentation/controllers/audit_events_controller.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/pages/audit_events_screen.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_data.dart';
import 'package:tisini/features/match_capture/domain/entities/match_score.dart';

class TimerController extends GetxController {
  static TimerController get instance => Get.find();

  MatchCaptureController get matchCaptureController => Get.find();

  AgentFixture get fixture => matchCaptureController.fixture.value!;
  List<MatchData>? get matchData => matchCaptureController.fixtureData.value;
  MatchScore? get matchScore => matchCaptureController.matchScore.value;
  void submitOwnGoal({required bool isHomeTeam}) =>
      matchCaptureController.submitOwnGoal(isHomeTeam: isHomeTeam);

  final StartMatchUsecase startMatchUsecase;
  final EndHalfUsecase endHalfUsecase;

  TimerController({
    required this.startMatchUsecase,
    required this.endHalfUsecase,
  });

  final box = GetStorage();

  Future<String?> getToken() async {
    return box.read('token') as String?;
  }

  final RxList<Formation> formations = RxList<Formation>([]);
  final Rx<Formation?> selectedFormation = Rx<Formation?>(null);

  final RxBool isHomeTeam = true.obs;
  final RxBool isSecondHalf = false.obs;
  final RxInt secondsElapsed = 0.obs;
  final RxBool isRunning = false.obs;
  Timer? _timer;
  final RxString quarter = "".obs;
  final RxString half = "".obs;
  final RxInt homeScore = 0.obs;
  final RxInt awayScore = 0.obs;

  // Keys
  String get _secondsKey => "${fixture.id.toString()}_seconds";
  String get _runningKey => "${fixture.id.toString()}_running";
  String get _quarterKey => "${fixture.id.toString()}_quarter";
  String get _halfKey => "${fixture.id.toString()}_half";
  String get _isSecondHalfKey => "${fixture.id.toString()}_isSecondHalf";

  // Replace your formattedTime getter with this:
  final RxString formattedTime = "00:00".obs;

  // Add this method to update the formatted time:
  void _updateFormattedTime() {
    final minutes = (secondsElapsed.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsElapsed.value % 60).toString().padLeft(2, '0');
    formattedTime.value = '$minutes:$seconds';
  }

  /// Fresh-match default: basketball counts down from 12:00; others from 0.
  int _defaultSeconds() => fixture.fixtureType == 'basketball' ? 720 : 0;

  int? _readStoredSeconds() {
    final raw = box.read(_secondsKey);
    if (raw == null) return null;
    return int.tryParse('$raw');
  }

  int _secondsFromServer() => (fixture.minute * 60) + fixture.second;

  /// Restore order: local save → server clock → sport default.
  int _resolveRestoredSeconds() {
    final stored = _readStoredSeconds();
    if (stored != null) return stored;

    if (fixture.fixtureType == 'basketball') {
      return _defaultSeconds();
    }

    final server = _secondsFromServer();
    if (server > 0) return server;

    return _defaultSeconds();
  }

  bool get _isInProgressMatch =>
      fixture.gameStatus == 'started' ||
      fixture.gameStatus == 'HT' ||
      fixture.gameStatus == 'FT';

  @override
  void onInit() {
    super.onInit();

    if (_isInProgressMatch) {
      secondsElapsed.value = _resolveRestoredSeconds();
      isRunning.value = box.read(_runningKey) ?? false;
      half.value = box.read(_halfKey) ?? "firsthalf";
      quarter.value = box.read(_quarterKey) ?? "first";
      isSecondHalf.value =
          box.read(_isSecondHalfKey) ?? (half.value == 'secondhalf');
    } else {
      isRunning.value = false;
      half.value = "firsthalf";
      quarter.value = "first";
      secondsElapsed.value = _defaultSeconds();
    }

    // Update formatted time immediately
    _updateFormattedTime();

    // Persist and format updates together
    ever(secondsElapsed, (int val) {
      _updateFormattedTime();
      box.write(_secondsKey, val);
    });

    ever(isRunning, (bool val) => box.write(_runningKey, val));
    ever(quarter, (String val) => box.write(_quarterKey, val));
    ever(half, (String val) => box.write(_halfKey, val));
    ever(isSecondHalf, (bool val) => box.write(_isSecondHalfKey, val));

    if (isRunning.value && fixture.gameStatus == 'started') {
      startTimer();
    }

    getFormations();
  }

  void goToAuditEvents() {
    Get.toNamed("/audit-events");
  }

  void toggleTeam() {
    isHomeTeam.value = !isHomeTeam.value;
    if (Get.isRegistered<MatchCaptureController>()) {
      Get.find<MatchCaptureController>().cancelReorderMode();
    }
  }

  void getFormations() {
    final fixtureType = fixture.fixtureType;

    if (fixtureType == "football") {
      formations.assignAll(FormationConstants.footballFormations);
      selectedFormation.value = FormationConstants.footballFormations[0];
    } else if (fixtureType == "rugby15") {
      formations.assignAll(FormationConstants.rugby15Formations);
      selectedFormation.value = FormationConstants.rugby15Formations[0];
    } else if (fixtureType == "rugby10") {
      formations.assignAll(FormationConstants.rugby10Formations);
      selectedFormation.value = FormationConstants.rugby10Formations[0];
    } else if (fixtureType == "rugby7") {
      formations.assignAll(FormationConstants.rugby7Formations);
      selectedFormation.value = FormationConstants.rugby7Formations[0];
    } else if (fixtureType == "basketball") {
      formations.assignAll(FormationConstants.basketballFormations);
      selectedFormation.value = FormationConstants.basketballFormations[0];
    } else if (fixtureType == "hockey") {
      formations.assignAll(FormationConstants.hockeyFormations);
      selectedFormation.value = FormationConstants.hockeyFormations[0];
    } else if (fixtureType == "handball") {
      formations.assignAll(FormationConstants.handballFormations);
      selectedFormation.value = FormationConstants.handballFormations[0];
    } else {
      formations.assignAll([]);
      selectedFormation.value = null;
    }
  }

  void changeFormation(Formation formation) {
    selectedFormation.value = formation;
  }

  void startTimer() {
    // Only skip if a timer is actually running (not just isRunning from persistence)
    if (_timer?.isActive ?? false) {
      debugPrint("Timer already running");
      return;
    }

    try {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (fixture.fixtureType == 'basketball') {
          secondsElapsed.value--;
        } else {
          secondsElapsed.value++;
          switch (secondsElapsed.value) {
            case 900: // 15 min
            case 1800: // 30 min
            case 3600: // 60 min
            case 4500: // 75 min
              updateQuarter();
              break;
          }
        }
        // debugPrint(
        //   "Timer tick: ${secondsElapsed.value} seconds || ${quarter.value} || ${half.value}",
        // );
      });
      isRunning.value = true;
      // debugPrint("Timer started successfully");
    } catch (e) {
      debugPrint("Error starting timer: $e");
    }
  }

  void pause() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void resetTimer() {
    pause();
    secondsElapsed.value = _defaultSeconds();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void updateQuarter() {
    if (fixture.fixtureType == 'football') {
      if (quarter.value == 'first') {
        quarter.value = 'second';
      } else if (quarter.value == 'second') {
        quarter.value = 'third';
      } else if (quarter.value == 'fourth') {
        quarter.value = 'fifth';
      } else if (quarter.value == 'fifth') {
        quarter.value = 'sixth';
      } else if (quarter.value == 'sixth') {
        quarter.value = 'extra';
      }
    }
  }

  String matchQuarter() {
    if (quarter.value == 'first') {
      return "1";
    } else if (quarter.value == 'second') {
      return "2";
    } else if (quarter.value == 'third') {
      return "3";
    } else if (quarter.value == 'fourth') {
      return "4";
    } else if (quarter.value == 'fifth') {
      return "5";
    } else if (quarter.value == 'sixth') {
      return "6";
    } else {
      return "1";
    }
  }

  void endQuarter() {
    if (fixture.fixtureType == 'basketball') {
      if (quarter.value == 'first') {
        quarter.value = 'second';
      } else if (quarter.value == 'second') {
        half.value = 'secondhalf';
        quarter.value = 'third';
      } else if (quarter.value == 'third') {
        quarter.value = 'fourth';
      }
      resetTimer();
    }
  }

  void endMatch() async {
    final token = await getToken() ?? '';

    if (token.isEmpty) {
      showSnackbar(
        "Error",
        "Token is required",
        Colors.red,
        position: SnackPosition.TOP,
      );
      return;
    }

    final response = await endHalfUsecase.call(
      EndHalfParams(
        token: token,
        fixtureId: fixture.id.toString(),
        minute: formattedTime.split(":")[0],
        second: formattedTime.split(":")[1],
        status: "FT",
        moment: "ended",
      ),
    );

    pause();
    response.fold(
      (failure) {
        showSnackbar(
          "Error",
          failure.message,
          Colors.red,
          position: SnackPosition.TOP,
        );
      },
      (success) {
        showSnackbar(
          "Success",
          success,
          Colors.green,
          position: SnackPosition.TOP,
        );
      },
    );

    Get.offAllNamed("/dashboard");
  }

  void endMatchHalf() async {
    final token = await getToken() ?? '';

    if (token.isEmpty) {
      showSnackbar(
        "Error",
        "Token is required",
        Colors.red,
        position: SnackPosition.TOP,
      );
      Get.offAllNamed("/dashboard");
    }

    final response = await endHalfUsecase.call(
      EndHalfParams(
        token: token,
        fixtureId: fixture.id.toString(),
        minute: formattedTime.split(":")[0],
        second: formattedTime.split(":")[1],
        status: "HT",
        moment: "secondhalf",
      ),
    );

    response.fold(
      (failure) {
        showSnackbar(
          "Error",
          failure.message,
          Colors.red,
          position: SnackPosition.TOP,
        );
      },
      (success) {
        debugPrint("End half success: $success");
        if (half.value == 'firsthalf') {
          pause();
          half.value = 'secondhalf';
          isSecondHalf.value = true;

          if (fixture.fixtureType == 'football') {
            secondsElapsed.value = 2700;
            quarter.value = 'fourth';
          } else if (fixture.fixtureType == 'rugby15') {
            secondsElapsed.value = 2400;
            quarter.value = 'fourth';
          } else if (fixture.fixtureType == 'basketball') {
            secondsElapsed.value = 720;
            quarter.value = 'fourth';
          } else if (fixture.fixtureType == 'rugby7') {
            secondsElapsed.value = 420;
            quarter.value = 'second';
          } else if (fixture.fixtureType == 'rugby10') {
            secondsElapsed.value = 900;
            quarter.value = 'fourth';
          } else if (fixture.fixtureType == 'hockey') {
            secondsElapsed.value = 1800;
            quarter.value = 'fourth';
          }
        }
        Get.offAllNamed("/dashboard");
      },
    );
  }

  void resumeMatch() {
    startTimer();
  }

  void startMatch() async {
    try {
      final token = await getToken() ?? '';

      if (token.isEmpty) {
        showSnackbar(
          "Error",
          "Token is required",
          Colors.red,
          position: SnackPosition.TOP,
        );
        return;
      }

      // Start timer immediately for better UX
      startTimer();
      debugPrint("Starting match, fixture id: ${fixture.id.toString()}");
      debugPrint("Token: $token");
      final response = await startMatchUsecase.call(
        StartMatchParams(token: token, fixtureId: fixture.id.toString()),
      );

      response.fold(
        (failure) {
          resetTimer();
          showSnackbar(
            "Error",
            failure.message,
            Colors.red,
            position: SnackPosition.TOP,
          );
        },
        (success) {
          showSnackbar(
            "Success",
            success,
            Colors.green,
            position: SnackPosition.TOP,
          );
        },
      );
    } catch (e) {
      // Stop timer on error
      resetTimer();
      debugPrint("Error starting match: $e");
    }
  }

  String getScores(String teamId) {
    if (teamId == fixture.team1Id.toString()) {
      return matchScore?.home.toString() ?? '0';
    } else {
      return matchScore?.away.toString() ?? '0';
    }
  }
}
