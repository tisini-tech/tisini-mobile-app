import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

class MultipleStatsContainer extends StatelessWidget {
  const MultipleStatsContainer({
    super.key,
    required this.child,
    required this.title,
  });

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.03),
      margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: TColors.darkContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 3),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1)),
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
