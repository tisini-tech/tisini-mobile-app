import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/fixtures/presentation/widgets/single_stats_.dart';
import 'package:tisini/features/fixtures/presentation/widgets/stats_acc_row.dart';
import 'package:tisini/features/fixtures/presentation/widgets/stats_row.dart';
import 'package:tisini/features/fixtures/presentation/controllers/fixture_details_controller.dart';

class RugbyGeneralStats extends GetView<FixtureDetailsController> {
  const RugbyGeneralStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.fixtureDetails.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final matchData = controller.fixtureDetails.value?.stats;
      final homeStats = matchData?.home ?? [];
      final awayStats = matchData?.away ?? [];

      final homeOnly = homeStats.isNotEmpty && awayStats.isEmpty;
      final awayOnly = awayStats.isNotEmpty && homeStats.isEmpty;
      final both = homeStats.isNotEmpty && awayStats.isNotEmpty;

      final homeRed = controller.findSubEvent(homeStats, 260, "693");
      final awayRed = controller.findSubEvent(awayStats, 260, "693");

      final homePass =
          controller.findStats(homeStats, 91) +
          controller.findStats(homeStats, 241);
      final awayPass =
          controller.findStats(awayStats, 91) +
          controller.findStats(awayStats, 241);

      final totalHPasses =
          homePass +
          controller.findStats(homeStats, 87) +
          controller.findStats(homeStats, 40);
      final totalAPasses =
          awayPass +
          controller.findStats(awayStats, 87) +
          controller.findStats(awayStats, 40);

      final homeVisits =
          controller.findStats(homeStats, 122) +
          controller.findStats(homeStats, 104) +
          controller.findStats(homeStats, 123) +
          controller.findStats(homeStats, 245);
      final awayVisits =
          controller.findStats(awayStats, 122) +
          controller.findStats(awayStats, 104) +
          controller.findStats(awayStats, 123) +
          controller.findStats(awayStats, 245);

      final homeTries =
          controller.findSubEvent(homeStats, 33, "51") +
          controller.findSubEvent(homeStats, 33, "142") +
          controller.findSubEvent(homeStats, 49, "66") +
          controller.findSubEvent(homeStats, 49, "200") +
          controller.findSubEvent(homeStats, 79, "91") +
          controller.findSubEvent(homeStats, 79, "201") +
          controller.findSubEvent(homeStats, 253, "638") +
          controller.findSubEvent(homeStats, 253, "639");

      final awayTries =
          controller.findSubEvent(awayStats, 33, "51") +
          controller.findSubEvent(awayStats, 33, "142") +
          controller.findSubEvent(awayStats, 49, "66") +
          controller.findSubEvent(awayStats, 49, "200") +
          controller.findSubEvent(awayStats, 79, "91") +
          controller.findSubEvent(awayStats, 79, "201") +
          controller.findSubEvent(awayStats, 253, "638") +
          controller.findSubEvent(awayStats, 253, "639");

      final homeSuccKicks =
          controller.findSubEvent(homeStats, 33, "52") +
          controller.findSubEvent(homeStats, 49, "60") +
          controller.findSubEvent(homeStats, 79, "92") +
          controller.findSubEvent(homeStats, 79, "311") +
          controller.findSubEvent(homeStats, 49, "44") +
          controller.findSubEvent(homeStats, 79, "94") +
          controller.findSubEvent(homeStats, 33, "53") +
          controller.findSubEvent(homeStats, 253, "635") +
          controller.findSubEvent(homeStats, 253, "634");
      final awaySuccKicks =
          controller.findSubEvent(awayStats, 33, "52") +
          controller.findSubEvent(awayStats, 49, "60") +
          controller.findSubEvent(awayStats, 79, "92") +
          controller.findSubEvent(awayStats, 79, "311") +
          controller.findSubEvent(awayStats, 49, "44") +
          controller.findSubEvent(awayStats, 79, "94") +
          controller.findSubEvent(awayStats, 33, "53") +
          controller.findSubEvent(awayStats, 253, "635") +
          controller.findSubEvent(awayStats, 253, "634");

      final homeTotalKicks =
          homeSuccKicks +
          controller.findSubEvent(homeStats, 33, "69") +
          controller.findSubEvent(homeStats, 49, "42") +
          controller.findSubEvent(homeStats, 79, "93") +
          controller.findSubEvent(homeStats, 33, "70") +
          controller.findSubEvent(homeStats, 49, "61") +
          controller.findSubEvent(homeStats, 79, "95") +
          controller.findSubEvent(homeStats, 253, "632") +
          controller.findSubEvent(homeStats, 253, "636");
      final awayTotalKicks =
          awaySuccKicks +
          controller.findSubEvent(awayStats, 33, "69") +
          controller.findSubEvent(awayStats, 49, "42") +
          controller.findSubEvent(awayStats, 79, "93") +
          controller.findSubEvent(awayStats, 33, "70") +
          controller.findSubEvent(awayStats, 49, "61") +
          controller.findSubEvent(awayStats, 79, "95") +
          controller.findSubEvent(awayStats, 253, "632") +
          controller.findSubEvent(awayStats, 253, "636");

      final homeHandlingErrors =
          controller.findStats(homeStats, 35) +
          controller.findStats(homeStats, 41) +
          controller.findStats(homeStats, 112) +
          controller.findStats(homeStats, 86) +
          controller.findStats(homeStats, 87) +
          controller.findStats(homeStats, 119) +
          controller.findStats(homeStats, 36) +
          controller.findStats(homeStats, 40) +
          controller.findStats(homeStats, 80) +
          controller.findStats(homeStats, 149) +
          controller.findStats(homeStats, 103) +
          controller.findStats(homeStats, 145) +
          controller.findStats(homeStats, 255);

      final awayHandlingErrors =
          controller.findStats(awayStats, 35) +
          controller.findStats(awayStats, 41) +
          controller.findStats(awayStats, 112) +
          controller.findStats(awayStats, 86) +
          controller.findStats(awayStats, 87) +
          controller.findStats(awayStats, 119) +
          controller.findStats(awayStats, 36) +
          controller.findStats(awayStats, 40) +
          controller.findStats(awayStats, 80) +
          controller.findStats(awayStats, 149) +
          controller.findStats(awayStats, 103) +
          controller.findStats(awayStats, 145) +
          controller.findStats(awayStats, 255);

      final homeTurnOvers =
          controller.findStats(homeStats, 45) +
          controller.findStats(homeStats, 59) +
          controller.findStats(homeStats, 77) +
          controller.findStats(homeStats, 258);

      final awayTurnOvers =
          controller.findStats(awayStats, 45) +
          controller.findStats(awayStats, 59) +
          controller.findStats(awayStats, 77) +
          controller.findStats(awayStats, 258);

      return Column(
        children: [
          // SizedBox(
          //   child: both
          //       ? SingleStatsContainer(
          //           child: StatsRow(
          //             homeStat: controller.calculatePossession(
          //               homeStats,
          //               awayStats,
          //             )['home']!,
          //             awayStat: controller.calculatePossession(
          //               homeStats,
          //               awayStats,
          //             )['away']!,
          //             statsTitle: 'Posession %',
          //           ),
          //         )
          //       : const SizedBox.shrink(),
          // ),

          // Visit in Opp 22
          SingleStatsContainer(
            child: StatsRow(
              homeStat: homeOnly || both ? homeVisits.toString() : '-',
              awayStat: awayOnly || both ? awayVisits.toString() : '-',
              statsTitle: 'Visit in Opp 22',
            ),
          ),

          // Tries
          SingleStatsContainer(
            child: StatsRow(
              homeStat: homeOnly || both ? homeTries.toString() : '-',
              awayStat: awayOnly || both ? awayTries.toString() : '-',
              statsTitle: 'Tries Scored',
            ),
          ),

          // Successful kicks
          SingleStatsContainer(
            child: StatsAccRow(
              stat: 'Successful Kicks',
              label: 'Conversion rate',
              homeCount: homeOnly || both
                  ? '$homeSuccKicks/$homeTotalKicks'
                  : '-',
              awayCount: awayOnly || both
                  ? '$awaySuccKicks/$awayTotalKicks'
                  : '-',
              awayPercentage: awayOnly || both
                  ? controller.calculateAccuracy(awayTotalKicks, awaySuccKicks)
                  : 0.0,
              homePercentage: homeOnly || both
                  ? controller.calculateAccuracy(homeTotalKicks, homeSuccKicks)
                  : 0.0,
            ),
          ),

          // Handling errors
          SingleStatsContainer(
            child: StatsRow(
              homeStat: homeOnly || both ? homeHandlingErrors.toString() : '-',
              awayStat: awayOnly || both ? awayHandlingErrors.toString() : '-',
              statsTitle: 'Handling Errors',
            ),
          ),

          // Turn overs
          SingleStatsContainer(
            child: StatsRow(
              homeStat: homeOnly || both ? homeTurnOvers.toString() : '-',
              awayStat: awayOnly || both ? awayTurnOvers.toString() : '-',
              statsTitle: 'Turnovers Won',
            ),
          ),

          // Penalties conceded
          SingleStatsContainer(
            child: StatsRow(
              homeStat: homeOnly || both
                  ? controller.findStats(homeStats, 257).toString()
                  : '-',
              awayStat: awayOnly || both
                  ? controller.findStats(awayStats, 257).toString()
                  : '-',
              statsTitle: 'Penalties Conceded',
            ),
          ),

          // Yellow Cards
          SingleStatsContainer(
            child: StatsRow(
              homeStat: homeOnly || both
                  ? controller.findSubEvent(homeStats, 260, "694").toString()
                  : '-',
              awayStat: awayOnly || both
                  ? controller.findSubEvent(awayStats, 260, "694").toString()
                  : '-',
              statsTitle: 'Yellow Cards',
            ),
          ),

          // Red Cards
          SizedBox(
            child: homeRed != 0 && awayRed != 0
                ? SingleStatsContainer(
                    child: StatsRow(
                      homeStat: homeRed.toString(),
                      awayStat: awayRed.toString(),
                      statsTitle: 'Red Cards',
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}
