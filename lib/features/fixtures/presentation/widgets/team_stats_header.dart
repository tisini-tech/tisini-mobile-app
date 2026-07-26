import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/presentation/controllers/team_stats_controller.dart';
import 'package:tisini/features/fixtures/presentation/widgets/fixture_match_header.dart';

class TeamStatsHeader extends GetView<TeamStatsController> {
  const TeamStatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final refreshing = controller.isRefreshing.value;
      final fixture = controller.fixture;

      if (fixture == null) {
        return const Center(
          child: Text('No fixture', style: TextStyle(color: TColors.textWhite)),
        );
      }

      return FixtureMatchHeader(
        fixture: fixture,
        title: 'Match statistics',
        onBack: Get.back,
        trailing: IconButton(
          onPressed: refreshing ? null : controller.refresh,
          icon: refreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TColors.textWhite,
                  ),
                )
              : const Icon(Icons.refresh, color: TColors.textWhite),
        ),
      );
    });
  }
}
