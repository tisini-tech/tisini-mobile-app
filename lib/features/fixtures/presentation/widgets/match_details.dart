import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/site_images.dart';
import 'package:tisini/features/fixtures/presentation/controllers/fixture_details_controller.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/fixture_details_shimmer.dart';

class MatchDetails extends GetView<FixtureDetailsController> {
  const MatchDetails({super.key, this.title = true});

  final bool? title;

  String getLeagueLogo(String id) {
    final logos = leagues;
    return logos[id] ?? 'assets/images/awayLogo.png';
  }

  String getTeamLogo(String id, Map<String, String> map) {
    final logos = map;
    return logos[id] ?? 'assets/images/homeLogo.png';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const FixtureDetailsShimmer();
      } else if (controller.fixtureDetails.value == null) {
        return const Center(child: Text('No data available.'));
      }

      final fixture = controller.fixtureDetails.value?.fixture;

      var moment = "";

      if (fixture?.gameStatus == "started") {
        moment = fixture?.minute.toString() ?? "";
      } else if (fixture?.minute.toString() == "45" &&
          fixture?.gameMoment == "secondhalf" &&
          fixture?.second.toString() == "0") {
        moment = "Half-Time";
      } else if (fixture?.gameStatus == "HT" &&
          fixture?.gameMoment == "secondhalf") {
        moment = fixture?.minute.toString() ?? "";
      } else {
        moment = "Full-Time";
      }

      return Container(
        height: MediaQuery.sizeOf(context).height * 0.25,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            title == true
                ? Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: TColors.darkGrey),
                      ),
                    ),
                    child: SizedBox(
                      child: Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Image.asset(
                              getLeagueLogo(fixture?.league ?? ""),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${fixture?.league} - Round ${fixture?.matchday}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            // const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.sizeOf(context).width * 0.01,
                  top: MediaQuery.sizeOf(context).height * 0.01,
                  right: MediaQuery.sizeOf(context).width * 0.01,
                  bottom: MediaQuery.sizeOf(context).height * 0.02,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // HomeTeam Details
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.375,
                        child: Column(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: TColors.primaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  getTeamLogo(
                                    fixture?.team1Id.toString() ?? "",
                                    fixture?.fixtureType == "football"
                                        ? footballImages
                                        : rugbyImages,
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: Text(
                                fixture?.team1Name ?? "",
                                style: const TextStyle(
                                  color: TColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Scores Details
                    Expanded(
                      child: fixture?.gameStatus == "notstarted"
                          ? Text(
                              "vs",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.25,
                                  child: Text.rich(
                                    textAlign: TextAlign.center,
                                    TextSpan(
                                      style: const TextStyle(
                                        color: TColors.textWhite,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: fixture?.homeScore ?? "0",
                                        ),
                                        const TextSpan(text: ' : '),
                                        TextSpan(
                                          text: fixture?.awayScore ?? "0",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  moment,
                                  style: const TextStyle(
                                    color: TColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                    ),

                    // Away Details
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.375,
                        child: Column(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: TColors.primaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  getTeamLogo(
                                    fixture?.team2Id.toString() ?? "",
                                    fixture?.fixtureType == "football"
                                        ? footballImages
                                        : rugbyImages,
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: Text(
                                fixture?.team2Name ?? "",
                                style: const TextStyle(
                                  color: TColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
