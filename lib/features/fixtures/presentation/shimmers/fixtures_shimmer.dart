import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/dates_shimmer.dart';
import 'package:tisini/features/fixtures/presentation/widgets/fixture_dates_strip.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/fixture_shimmer_style.dart';

/// Full-page placeholder (dates strip + fixture list) for [FixturesScreen].
class FixturesPageShimmer extends StatelessWidget {
  const FixturesPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: FixtureDatesStrip.stripHeight, child: DatesShimmer()),
        const Expanded(child: FixturesShimmer()),
      ],
    );
  }
}

/// League cards + fixture rows placeholder for the fixtures list area.
class FixturesShimmer extends StatelessWidget {
  const FixturesShimmer({super.key, this.leagueCardCount = 3});

  final int leagueCardCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: leagueCardCount,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: _LeagueCardShimmer(),
      ),
    );
  }
}

class _LeagueCardShimmer extends StatelessWidget {
  const _LeagueCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColors.darkContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FixtureShimmerStyle.box(
            width: MediaQuery.sizeOf(context).width * 0.45,
            height: 20,
          ),
          const SizedBox(height: 20),
          const _FixtureRowShimmer(),
          const _FixtureRowShimmer(),
          const _FixtureRowShimmer(),
        ],
      ),
    );
  }
}

class _FixtureRowShimmer extends StatelessWidget {
  const _FixtureRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _shimmerBox(context, widthFactor: 0.2, height: 15),
                SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
                _shimmerCircle(40),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            flex: 2,
            child: _shimmerBox(context, widthFactor: 0.05, height: 20),
          ),
          const SizedBox(width: 15),
          Flexible(
            flex: 4,
            child: Row(
              children: [
                _shimmerCircle(40),
                SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
                _shimmerBox(context, widthFactor: 0.2, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _shimmerBox(
    BuildContext context, {
    required double widthFactor,
    required double height,
  }) {
    return FixtureShimmerStyle.box(
      width: MediaQuery.sizeOf(context).width * widthFactor,
      height: height,
    );
  }

  static Widget _shimmerCircle(double size) => FixtureShimmerStyle.circle(size);
}
