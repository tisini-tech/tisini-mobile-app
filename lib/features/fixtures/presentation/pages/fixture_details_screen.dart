import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/widgets/appbar/appbar.dart';
import 'package:tisini/core/widgets/bars/tabbar.dart';
import 'package:tisini/core/widgets/container/container_header.dart';
import 'package:tisini/features/fixtures/presentation/controllers/fixture_details_controller.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/fixture_stats_shimmer.dart';
import 'package:tisini/features/fixtures/presentation/widgets/details_tab.dart';
import 'package:tisini/features/fixtures/presentation/widgets/lineups_tab.dart';
import 'package:tisini/features/fixtures/presentation/widgets/match_details.dart';
import 'package:tisini/features/fixtures/presentation/widgets/stats_tab.dart';

class FixtureDetailsScreen extends GetView<FixtureDetailsController> {
  const FixtureDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        body: Column(
          children: [
            ContainerHeader(
              child: Column(
                children: [
                  // Custom AppBar showing league
                  TAppBar(
                    title: Image.asset("assets/tisini-logo.png", height: 50),
                  ),

                  // Match details section
                  const Expanded(child: MatchDetails(title: false)),
                ],
              ),
            ),
            const TTabbar(
              tabs: [
                Tab(child: Text('Details')),
                Tab(child: Text('Stats')),
                Tab(child: Text('Line Ups')),
              ],
            ),

            Expanded(
              child: Obx(() {
                final data = controller.fixtureDetails.value;

                if (controller.isLoading.value) {
                  return const FixtureStatsShimmer();
                }

                if (data == null) {
                  return const Center(child: Text('No fixture data'));
                }

                final details = data.highlights;
                final fixture = data.fixture;
                final lineups = controller.fixtureLineups.value;
                final lineupsLoading = controller.isLoadingLineups.value;

                return TabBarView(
                  children: [
                    // Details tab
                    DetailsTab(details: details, fixture: fixture),

                    // Stats tab
                    const StatsTab(),

                    // Lineups tab
                    lineupsLoading
                        ? const Center(child: CircularProgressIndicator())
                        : lineups == null
                        ? const Center(child: Text('No lineup data'))
                        : LineupsTab(lineups: lineups, fixture: fixture),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
