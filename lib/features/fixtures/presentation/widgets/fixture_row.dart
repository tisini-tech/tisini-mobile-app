import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/site_images.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture.dart';
import 'package:flutter/material.dart';
import 'package:tisini/features/fixtures/presentation/controllers/live_fixture_controller.dart';

class FixtureRow extends StatelessWidget {
  const FixtureRow({super.key, required this.fixture});

  final Fixture fixture;

  String getFootballLogo(String id) {
    final logos = footballImages;
    return logos[id] ?? 'assets/images/homeLogo.png';
  }

  String getRugbyLogo(String id) {
    final logos = rugbyImages;
    return logos[id] ?? 'assets/images/awayLogo.png';
  }

  @override
  Widget build(BuildContext context) {
    final LiveFixtureController fixtureController =
        LiveFixtureController.instance;

    String homeLogo = fixture.fixtureType == "football"
        ? getFootballLogo(fixture.team1Id.toString())
        : getRugbyLogo(fixture.team1Id.toString());

    String awayLogo = fixture.fixtureType == "football"
        ? getFootballLogo(fixture.team2Id.toString())
        : getRugbyLogo(fixture.team2Id.toString());

    var moment = "";

    if (fixture.gameStatus == "started") {
      moment = fixture.minute.toString();
    } else if (fixture.minute.toString() == "45" &&
        fixture.gameMoment == "secondhalf" &&
        fixture.second.toString() == "0") {
      moment = "HT";
    } else if (fixture.gameStatus == "HT" &&
        fixture.gameMoment == "secondhalf") {
      moment = fixture.minute.toString();
    } else {
      moment = "FT";
    }

    return InkWell(
      // splashColor: TColors.accent,
      onTap: () => fixtureController.goToSingleFixture(fixture.id.toString()),
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.sizeOf(context).height * 0.04,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      fixture.team1Name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: TColors.darkContainer,
                      shape: BoxShape.circle,
                      // border: Border.all(width: 1, color: TColors.darkerGrey),
                    ),
                    child: ClipOval(
                      child: Image.asset(homeLogo, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              flex: 2,
              child: fixture.gameStatus == 'notstarted'
                  ? Text(
                      fixture.matchtime == '' ? '  vs  ' : fixture.matchtime,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: fixture.homeScore.toString(),
                            style: TextStyle(
                              color:
                                  int.parse(fixture.homeScore.toString()) >
                                      int.parse(fixture.awayScore.toString())
                                  ? TColors.primary
                                  : TColors.grey,
                            ),
                          ),
                          const TextSpan(text: ' - '),
                          TextSpan(
                            text: fixture.awayScore.toString(),
                            style: TextStyle(
                              color:
                                  int.parse(fixture.awayScore.toString()) >
                                      int.parse(fixture.homeScore.toString())
                                  ? TColors.primary
                                  : TColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 15),
            Flexible(
              flex: 4,
              child: Row(
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: ClipOval(
                      child: Image.asset(awayLogo, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
                  Expanded(
                    child: Text(
                      fixture.team2Name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            fixture.gameStatus == "notstarted"
                ? const SizedBox()
                : Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: const BoxDecoration(
                      color: TColors.primaryBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      moment,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TColors.accent,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
