import 'package:flutter/material.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/fixture_shimmer_style.dart';

/// Horizontal date-chip placeholders for the livescores date strip.
class DatesShimmer extends StatelessWidget {
  const DatesShimmer({super.key, this.chipCount = 6});

  final int chipCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: chipCount,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, __) =>
          FixtureShimmerStyle.box(width: 50, height: 40, radius: 12),
    );
  }
}
