import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.homeStat,
    required this.awayStat,
    required this.statsTitle,
  });

  final String homeStat, awayStat, statsTitle;

  @override
  Widget build(BuildContext context) {
    final double homeValue = double.tryParse(homeStat) ?? 0;
    final double awayValue = double.tryParse(awayStat) ?? 0;
    final double totalValue = homeValue + awayValue;

    final double homePercentage = totalValue == 0
        ? 0
        : (homeValue / totalValue) * 100;
    final double awayPercentage = totalValue == 0
        ? 0
        : (awayValue / totalValue) * 100;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statsTitle == 'Posession'
                  ? '${double.parse(homeStat).toStringAsFixed(0)}%'
                  : homeStat,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(statsTitle, style: Theme.of(context).textTheme.titleSmall),
            Text(
              statsTitle == 'Posession'
                  ? '${double.parse(awayStat).toStringAsFixed(0)}%'
                  : awayStat,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SizedBox(
                height: 10,
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: TColors.dark,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    if (homePercentage > 0)
                      Positioned(
                        right: 0,
                        left: 100 - homePercentage,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: SizedBox(
                height: 10,
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: TColors.dark,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    if (awayPercentage > 0)
                      Positioned(
                        left: 0,
                        right: 100 - awayPercentage,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
