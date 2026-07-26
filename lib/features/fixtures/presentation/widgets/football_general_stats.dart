import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/fixtures/presentation/widgets/single_stats_.dart';
import 'package:tisini/features/fixtures/presentation/widgets/stats_acc_row.dart';
import 'package:tisini/features/fixtures/presentation/widgets/stats_row.dart';
import 'package:tisini/features/fixtures/presentation/controllers/fixture_details_controller.dart';

class FootballGeneralStats extends GetView<FixtureDetailsController> {
  const FootballGeneralStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final matchData = controller.fixtureDetails.value?.stats;

      final homeStats = matchData?.home ?? [];
      final awayStats = matchData?.away ?? [];

      final homeRed = controller.findSubEvent(homeStats, 5, "22");
      final awayRed = controller.findSubEvent(awayStats, 5, "22");

      final homeOnly = homeStats.isNotEmpty && awayStats.isEmpty;
      final awayOnly = awayStats.isNotEmpty && homeStats.isEmpty;
      final both = homeStats.isNotEmpty && awayStats.isNotEmpty;

      final homePass = controller.findStats(homeStats, 7);
      final awayPass = controller.findStats(awayStats, 7);

      final totalHPasses = homePass + controller.findStats(homeStats, 25);
      final totalAPasses = awayPass + controller.findStats(awayStats, 25);

      final homeShots =
          controller.findStats(homeStats, 165) +
          controller.findStats(homeStats, 156) +
          controller.findStats(homeStats, 238);
      final awayShots =
          controller.findStats(awayStats, 165) +
          controller.findStats(awayStats, 156) +
          controller.findStats(awayStats, 238);

      final onTargetHome =
          controller.findSubEvent(homeStats, 165, "422") +
          controller.findSubEvent(homeStats, 156, "405") +
          controller.findSubEvent(homeStats, 238, "606") +
          controller.findSubEvent(homeStats, 238, "610");
      final onTargetAway =
          controller.findSubEvent(awayStats, 165, "422") +
          controller.findSubEvent(awayStats, 156, "405") +
          controller.findSubEvent(awayStats, 238, "606") +
          controller.findSubEvent(awayStats, 238, "610");

      return Column(
        children: [
          // Posession
          SizedBox(
            child: both
                ? SingleStatsContainer(
                    child: StatsRow(
                      homeStat: controller.calculatePossession(
                        homeStats,
                        awayStats,
                      )['home']!,
                      awayStat: controller.calculatePossession(
                        homeStats,
                        awayStats,
                      )['away']!,
                      statsTitle: 'Posession %',
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Attempts
          SingleStatsContainer(
            child: StatsAccRow(
              stat: 'Total attempts',
              label: 'Conversion rate',
              homeCount: '$onTargetHome/$homeShots',
              awayCount: '$onTargetAway/$awayShots',
              awayPercentage: controller.calculateAccuracy(
                awayShots,
                onTargetAway,
              ),
              homePercentage: controller.calculateAccuracy(
                homeShots,
                onTargetHome,
              ),
            ),
          ),

          // Passes
          SingleStatsContainer(
            child: StatsAccRow(
              stat: 'Total passes',
              label: 'Conversion rate',
              homeCount: homeOnly || both ? '$homePass/$totalHPasses' : '-',
              awayCount: awayOnly || both ? '$awayPass/$totalAPasses' : '-',
              awayPercentage: awayOnly || both
                  ? controller.calculateAccuracy(totalAPasses, awayPass)
                  : 0.0,
              homePercentage: homeOnly || both
                  ? controller.calculateAccuracy(totalHPasses, homePass)
                  : 0.0,
            ),
          ),

          // Corner kicks
          SingleStatsContainer(
            child: StatsRow(
              homeStat: controller.findStats(homeStats, 3).toString(),
              awayStat: controller.findStats(awayStats, 3).toString(),
              statsTitle: 'Corner Kicks',
            ),
          ),

          // Offsides
          SingleStatsContainer(
            child: StatsRow(
              homeStat: controller.findStats(homeStats, 10).toString(),
              awayStat: controller.findStats(awayStats, 10).toString(),
              statsTitle: 'Offsides',
            ),
          ),

          // Fouls
          SingleStatsContainer(
            child: StatsRow(
              homeStat: homeOnly || both
                  ? controller.findSubEvent(homeStats, 11, "74").toString()
                  : '-',
              awayStat: awayOnly || both
                  ? controller.findSubEvent(awayStats, 11, "74").toString()
                  : '-',
              statsTitle: 'Fouls Committed',
            ),
          ),

          // Yellow Cards
          SingleStatsContainer(
            child: StatsRow(
              homeStat: homeOnly || both
                  ? controller.findSubEvent(homeStats, 5, "21").toString()
                  : '-',
              awayStat: awayOnly || both
                  ? controller.findSubEvent(awayStats, 5, "21").toString()
                  : '-',
              statsTitle: 'Yellow Cards',
            ),
          ),

          // Red Cards
          SizedBox(
            child: awayRed != 0 && homeRed != 0
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
