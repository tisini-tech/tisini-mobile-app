import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture.dart';
import 'package:tisini/features/fixtures/domain/usecases/fixture_dates.dart';
import 'package:tisini/features/fixtures/domain/usecases/fixtures.dart';

class LiveFixtureController extends GetxController {
  static LiveFixtureController get instance => Get.find();

  final GetFixtureDatesUsecase getFixtureDatesUsecase;
  final GetFixturesUsecase getFixturesUsecase;

  LiveFixtureController({
    required this.getFixtureDatesUsecase,
    required this.getFixturesUsecase,
  });

  final RxBool isLoadingDates = true.obs;
  final RxBool isLoadingFixtures = false.obs;
  final RxList<String> fixtureTypesList = RxList<String>(['football', 'rugby']);
  final Rx<String> fixtureType = 'football'.obs;

  /// API sport key (rugby tab uses `rugby7` on the backend).
  String get apiFixtureType =>
      fixtureType.value == 'rugby' ? 'rugby7' : fixtureType.value;
  final Rx<String> selectedDate = ''.obs;
  final RxList<String> allDatesList = RxList<String>();
  final RxList<Fixture> fixturesList = RxList<Fixture>();
  final RxMap<String, List<Fixture>> leagueFixtures =
      RxMap<String, List<Fixture>>();

  final ScrollController dateScrollController = ScrollController();

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    pickRandomFixtureType();
    loadInitialData();
  }

  void pickRandomFixtureType() {
    if (fixtureTypesList.isEmpty) return;
    fixtureType.value =
        fixtureTypesList[Random().nextInt(fixtureTypesList.length)];
  }

  Future<void> loadInitialData() async {
    if (!fixtureTypesList.contains(fixtureType.value)) {
      fixtureType.value = fixtureTypesList.first;
    }

    await reloadDatesAndFixtures();
  }

  /// Fetches dates + fixtures — use when [fixtureType] changes.
  Future<void> reloadDatesAndFixtures() async {
    fixturesList.clear();
    leagueFixtures.clear();
    await getFixtureDates();
    if (allDatesList.isEmpty) {
      selectedDate.value = '';
      fixturesList.clear();
      leagueFixtures.clear();
      return;
    }
    selectedDate.value = allDatesList.first;
    await getFixtures();
  }

  void selectDate(String date) {
    selectedDate.value = date;
    getFixtures();
  }

  Future<void> selectFixtureType(String type) async {
    if (fixtureType.value == type) return;
    fixtureType.value = type;
    await reloadDatesAndFixtures();
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    final formattedDate = DateFormat('d MMM').format(dateTime);
    return formattedDate.toString();
  }

  void goToSingleFixture(String fixtureId) {
    box.write('fixtureId', fixtureId);
    Get.toNamed('/fixture-details', arguments: {'fixtureId': fixtureId});
  }

  Map<String, List<Fixture>> groupFixtures(List<Fixture> fixtures) {
    Map<String, List<Fixture>> groupedFixtures = {};

    for (var fixture in fixtures) {
      String league = fixture.league;
      String matchday = fixture.matchday;

      String rugbyLeague = '$league- $matchday';

      if (fixture.fixtureType == 'football') {
        if (!groupedFixtures.containsKey(league)) {
          groupedFixtures[league] = [];
        }

        groupedFixtures[league]!.add(fixture);
      } else {
        if (!groupedFixtures.containsKey(rugbyLeague)) {
          groupedFixtures[rugbyLeague] = [];
        }

        groupedFixtures[rugbyLeague]!.add(fixture);
      }
    }

    return groupedFixtures;
  }

  Future<void> getFixtureDates() async {
    try {
      isLoadingDates.value = true;

      debugPrint('getFixtureDates: $apiFixtureType');
      final result = await getFixtureDatesUsecase(
        GetFixtureDatesParams(fixtureType: apiFixtureType),
      );

      result.fold(
        (failure) => showSnackbar(
          'Error fetching dates',
          failure.message,
          TColors.error,
        ),
        (success) => allDatesList.assignAll(success),
      );
    } finally {
      isLoadingDates.value = false;
    }
  }

  Future<void> getFixtures() async {
    if (selectedDate.value.isEmpty) return;

    try {
      isLoadingFixtures.value = true;

      final result = await getFixturesUsecase(
        GetFixturesParams(
          matchDate: selectedDate.value,
          fixtureType: apiFixtureType,
        ),
      );

      result.fold(
        (failure) {
          showSnackbar(
            'Error fetching fixtures',
            failure.message,
            TColors.error,
          );
        },
        (success) {
          fixturesList.assignAll(success);
          leagueFixtures.value = groupFixtures(success);
        },
      );
    } finally {
      isLoadingFixtures.value = false;
    }
  }
}
