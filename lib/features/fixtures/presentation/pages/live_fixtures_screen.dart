import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/appbar/fixtures_appbar.dart';
import 'package:tisini/features/fixtures/presentation/controllers/live_fixture_controller.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/dates_shimmer.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/fixtures_shimmer.dart';
import 'package:tisini/features/fixtures/presentation/widgets/fixture_container.dart';
import 'package:tisini/features/fixtures/presentation/widgets/fixture_dates_strip.dart';

class LiveFixturesScreen extends GetView<LiveFixtureController> {
  const LiveFixturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FixturesAppBar(),
      body: Obx(() {
        final dates = controller.allDatesList;
        final fixtures = controller.leagueFixtures;
        final loadingDates = controller.isLoadingDates.value;
        final loadingFixtures = controller.isLoadingFixtures.value;

        if (loadingDates && dates.isEmpty) {
          return Column(
            children: [
              const SizedBox(
                height: FixtureDatesStrip.stripHeight,
                child: DatesShimmer(),
              ),
              const Expanded(child: FixturesShimmer()),
            ],
          );
        }

        return Column(
          children: [
            loadingDates
                ? const SizedBox(
                    height: FixtureDatesStrip.stripHeight,
                    child: DatesShimmer(),
                  )
                : FixtureDatesStrip(
                    dates: dates,
                    selectedDate: controller.selectedDate.value,
                    scrollController: controller.dateScrollController,
                    enabled: !loadingFixtures,
                    onDateSelected: controller.selectDate,
                  ),
            Expanded(
              child: loadingFixtures && fixtures.isEmpty
                  ? const FixturesShimmer()
                  : fixtures.isEmpty
                  ? Center(
                      child: Text(
                        'No fixtures for this date',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: TColors.textSecondary,
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          itemCount: fixtures.entries.length,
                          itemBuilder: (context, index) {
                            final entry = fixtures.entries.elementAt(index);
                            return FixtureContainer(
                              league: entry.value.first.leagueName,
                              fixtures: entry.value,
                            );
                          },
                        ),
                        if (loadingFixtures)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: ColoredBox(
                                color: TColors.light.withValues(alpha: 0.65),
                                child: const FixturesShimmer(
                                  leagueCardCount: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }
}
