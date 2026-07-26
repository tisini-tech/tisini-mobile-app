import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/presentation/shimmers/fixture_shimmer_style.dart';

/// Header placeholder (teams + score) for [MatchDetails] on fixture details.
class FixtureDetailsShimmer extends StatelessWidget {
  const FixtureDetailsShimmer({super.key, this.title});

  final bool? title;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.25,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (title == true)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: TColors.darkGrey),
                ),
              ),
              child: FixtureShimmerStyle.box(
                width: width * 0.45,
                height: 20,
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: width * 0.01,
                top: MediaQuery.sizeOf(context).height * 0.01,
                right: width * 0.01,
                bottom: MediaQuery.sizeOf(context).height * 0.02,
              ),
              child: Row(
                children: [
                  Expanded(child: _teamColumn(width)),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FixtureShimmerStyle.box(
                          width: width * 0.15,
                          height: 32,
                        ),
                        const SizedBox(height: 8),
                        FixtureShimmerStyle.box(
                          width: width * 0.12,
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _teamColumn(width)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamColumn(double width) {
    return Column(
      children: [
        FixtureShimmerStyle.circle(65),
        const SizedBox(height: 5),
        FixtureShimmerStyle.box(width: width * 0.25, height: 16),
      ],
    );
  }
}
