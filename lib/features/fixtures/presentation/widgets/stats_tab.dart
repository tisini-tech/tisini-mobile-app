import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/fixtures/presentation/controllers/fixture_details_controller.dart';
import 'package:tisini/features/fixtures/presentation/widgets/football_general_stats.dart';
import 'package:tisini/features/fixtures/presentation/widgets/rugby_general_stats.dart';

class StatsTab extends GetView<FixtureDetailsController> {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fixture = controller.fixtureDetails.value?.fixture;
      if (fixture == null) {
        return const Center(child: Text('No stats available'));
      }

      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.sizeOf(context).width * 0.025,
            right: MediaQuery.sizeOf(context).width * 0.025,
            bottom: MediaQuery.sizeOf(context).height * 0.01,
          ),
          child: fixture.fixtureType == 'football'
              ? const FootballGeneralStats()
              : const RugbyGeneralStats(),
        ),
      );
    });
  }
}
