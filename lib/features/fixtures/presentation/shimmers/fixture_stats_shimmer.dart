import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/fixture_shimmer_style.dart';

/// Stats tab placeholder for fixture details / single fixture screens.
class FixtureStatsShimmer extends StatelessWidget {
  const FixtureStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: width * 0.025,
          right: width * 0.025,
          bottom: height * 0.01,
        ),
        child: Column(
          children: [
            _statsCard(
              context,
              child: _statsRowShimmer(width),
            ),
            _statsCard(
              context,
              titleWidth: width * 0.35,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _statsRowShimmer(width),
                  const SizedBox(height: 30),
                  _statsRowShimmer(width),
                  const SizedBox(height: 30),
                  _statsRowShimmer(width),
                  const SizedBox(height: 30),
                  _statsRowShimmer(width),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _statsCard(
              context,
              titleWidth: width * 0.35,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _statsRowShimmer(width),
                  const SizedBox(height: 30),
                  _statsRowShimmer(width),
                  const SizedBox(height: 30),
                  _statsRowShimmer(width),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsCard(
    BuildContext context, {
    required Widget child,
    double? titleWidth,
  }) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      padding: EdgeInsets.all(width * 0.03),
      margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: TColors.darkContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleWidth != null) ...[
            FixtureShimmerStyle.box(width: titleWidth, height: 15),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _statsRowShimmer(double width) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FixtureShimmerStyle.box(width: width * 0.2, height: 15),
            FixtureShimmerStyle.box(width: width * 0.2, height: 15),
            FixtureShimmerStyle.box(width: width * 0.2, height: 15),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FixtureShimmerStyle.box(width: double.infinity, height: 10),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: FixtureShimmerStyle.box(width: double.infinity, height: 10),
            ),
          ],
        ),
      ],
    );
  }
}
