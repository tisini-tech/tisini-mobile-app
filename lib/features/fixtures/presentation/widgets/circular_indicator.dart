import 'package:tisini/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CircularPercentageIndicator extends StatelessWidget {
  const CircularPercentageIndicator({
    super.key,
    required this.percentage,
    required this.foregroundColor,
  });

  final double percentage;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: CircularProgressIndicator(
            value: percentage / 100,
            backgroundColor: TColors.dark,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            strokeWidth: 6,
          ),
        ),
        Positioned(
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}
