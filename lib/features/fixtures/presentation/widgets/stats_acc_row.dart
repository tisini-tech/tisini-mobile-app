import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/presentation/widgets/circular_indicator.dart';

class StatsAccRow extends StatelessWidget {
  const StatsAccRow({
    super.key,
    required this.label,
    required this.homeCount,
    required this.awayCount,
    required this.awayPercentage,
    required this.homePercentage,
    required this.stat,
  });

  final double awayPercentage, homePercentage;
  final String homeCount, awayCount, stat, label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(homeCount, style: Theme.of(context).textTheme.titleSmall),
            CircularPercentageIndicator(
              percentage: homePercentage,
              foregroundColor: TColors.primary,
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.2,
              child: Text(
                stat,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),
            CircularPercentageIndicator(
              percentage: awayPercentage,
              foregroundColor: TColors.warning,
            ),
            Text(awayCount, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
