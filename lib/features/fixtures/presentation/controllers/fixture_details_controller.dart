import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_detail.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_lineup.dart';
import 'package:tisini/features/fixtures/domain/usecases/fixture_details.dart';
import 'package:tisini/features/fixtures/domain/usecases/fixture_lineups.dart';

class FixtureDetailsController extends GetxController {
  static FixtureDetailsController get instance => Get.find();

  final GetFixtureLineupsUsecase getFixtureLineupsUsecase;
  final GetFixtureDetailsUsecase getFixtureDetailsUsecase;

  FixtureDetailsController({
    required this.getFixtureDetailsUsecase,
    required this.getFixtureLineupsUsecase,
  });

  final _box = GetStorage();

  final RxBool isLoading = true.obs;
  final RxBool isLoadingLineups = true.obs;
  final Rx<String> fixtureId = ''.obs;
  final Rx<FixtureDetails?> fixtureDetails = Rx<FixtureDetails?>(null);
  final Rx<FixtureLineups?> fixtureLineups = Rx<FixtureLineups?>(null);

  bool _loadStarted = false;

  @override
  void onInit() {
    super.onInit();
    _loadOnce();
  }

  Future<void> _loadOnce() async {
    if (_loadStarted) return;
    _loadStarted = true;

    fixtureId.value = _resolveFixtureId();
    if (fixtureId.value.isEmpty) {
      showSnackbar('Error', 'No fixture selected', TColors.error);
      Get.back();
      return;
    }

    // Load both details and lineups in parallel
    await Future.wait([getFixtureDetails(), getFixtureLineups()]);
  }

  String _resolveFixtureId() {
    final args = Get.arguments;
    if (args is Map) {
      final fromArgs = args['fixtureId']?.toString() ?? '';
      if (fromArgs.isNotEmpty) return fromArgs;
    }
    return _box.read('fixtureId')?.toString() ?? '';
  }

  int findStats(List<EventStats> stats, int eventId) {
    for (final item in stats) {
      if (item.eventId == eventId) return item.total;
    }
    return 0;
  }

  int findSubEvent(List<EventStats> stats, int eventId, String subEventId) {
    for (final item in stats) {
      if (item.eventId != eventId) continue;
      for (final sub in item.subEvents) {
        if (sub.subEventId == subEventId) return sub.total;
      }
      return 0;
    }
    return 0;
  }

  double calculateAccuracy(int total, int stat) {
    if (total == 0) return 0.0;

    double result = (stat / total) * 100;
    return result.roundToDouble();
  }

  Map<String, String> calculatePossession(
    List<EventStats> home,
    List<EventStats> away,
  ) {
    final homePass = findStats(home, 7);
    final awayPass = findStats(away, 7);
    final totalPasses = homePass + awayPass;

    if (totalPasses == 0) {
      return {'home': '0', 'away': '0'};
    }

    final homePossession = (homePass / totalPasses) * 100;
    final awayPossession = (awayPass / totalPasses) * 100;

    return {
      'home': homePossession.round().toString(),
      'away': awayPossession.round().toString(),
    };
  }

  Future<void> getFixtureDetails() async {
    if (fixtureId.value.isEmpty) return;

    try {
      isLoading.value = true;

      final result = await getFixtureDetailsUsecase(
        GetFixtureDetailsParams(fixtureId: fixtureId.value),
      );

      result.fold(
        (failure) {
          showSnackbar('Error', failure.message, TColors.error);
        },
        (success) {
          fixtureDetails.value = success;
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getFixtureLineups() async {
    if (fixtureId.value.isEmpty) return;

    try {
      isLoadingLineups.value = true;

      final result = await getFixtureLineupsUsecase(
        GetFixtureLineupsParams(fixtureId: fixtureId.value),
      );

      result.fold(
        (failure) {
          showSnackbar('Error', failure.message, TColors.error);
        },
        (success) {
          fixtureLineups.value = success;
        },
      );
    } finally {
      isLoadingLineups.value = false;
    }
  }
}
