import 'package:get/get.dart';
import 'package:tisini/core/constants/site_images.dart' as site_images;

class LeagueFixtureController extends GetxController {
  static LeagueFixtureController get instance => Get.find();

  final RxList<Map<String, String>> leagues = <Map<String, String>>[
    {'name': 'Sportpesa Premier League', 'id': '205'},
    {'name': 'FKF Women Premier League', 'id': '206'},
    {'name': 'FKF National Super League', 'id': '158'},
  ].obs;

  String logoFor(String leagueId) =>
      site_images.leagues[leagueId] ?? 'assets/images/awayLogo.png';

  void openLeague(Map<String, String> league) {
    Get.toNamed(
      '/fixtures',
      arguments: {
        'fixtureType': 'football',
        'leagueId': league['id'],
        'leagueName': league['name'],
      },
    );
  }
}
