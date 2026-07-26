import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/container/container_header.dart';
import 'package:tisini/features/fixtures/presentation/controllers/team_stats_controller.dart';
import 'package:tisini/features/fixtures/presentation/widgets/match_event_stat_tile.dart';
import 'package:tisini/features/fixtures/presentation/widgets/team_stats_header.dart';

class TeamStatsScreen extends GetView<TeamStatsController> {
  const TeamStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.32,
            child: ContainerHeader(
              height: MediaQuery.sizeOf(context).height * 0.32,
              child: const TeamStatsHeader(),
            ),
          ),
          Expanded(child: _statsBody(context)),
        ],
      ),
    );
  }

  Widget _statsBody(BuildContext context) {
    return Obx(() {
      final _ = controller.expandedEventIds.length;

      if ((controller.isLoading.value || controller.isRefreshing.value) &&
          controller.stats.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.stats.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No match statistics yet.\nCapture events to see stats here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: TColors.textSecondary,
                  ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        color: TColors.primary,
        onRefresh: controller.refresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: controller.stats.length,
          itemBuilder: (context, index) {
            final event = controller.stats[index];
            return MatchEventStatTile(
              event: event,
              expanded: controller.isExpanded(event.eventId),
              onToggle: () => controller.toggleExpanded(event.eventId),
            );
          },
        ),
      );
    });
  }
}
