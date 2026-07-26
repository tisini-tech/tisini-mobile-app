import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

class SingleStatsContainer extends StatelessWidget {
  const SingleStatsContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.03),
      margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: TColors.darkContainer,
      ),
      child: child,
    );
  }
}
