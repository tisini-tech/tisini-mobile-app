import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/presentation/controllers/fixture_event_carousel_controller.dart';
import 'package:tisini/features/match_capture/presentation/controllers/timer_controller.dart';

/// Rotating home / event name + period / away stats from fixture event totals.
class FixtureEventStatsRow extends GetView<FixtureEventCarouselController> {
  const FixtureEventStatsRow({super.key});

  TimerController get _timer => Get.find<TimerController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Obx(() {
        final event = controller.currentEvent;
        final index = controller.currentIndex.value;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Row(
            key: ValueKey(event?.eventId ?? 'empty_$index'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _sideCount(event?.homeCount)),
              Expanded(flex: 2, child: _centerPanel(event?.eventName)),
              Expanded(child: _sideCount(event?.awayCount)),
            ],
          ),
        );
      }),
    );
  }

  Widget _sideCount(int? count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        count?.toString() ?? '—',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.lightGreenAccent,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _centerPanel(String? eventName) {
    return Obx(() {
      final period = _timer.matchQuarter();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              eventName?.isNotEmpty == true ? eventName! : 'Stats',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: TColors.textWhite,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: TColors.secondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                period,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
