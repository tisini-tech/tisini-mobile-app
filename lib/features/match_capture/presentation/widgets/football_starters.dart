import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';

class FootballStarters extends GetView<MatchCaptureController> {
  final List<Lineup> starters;
  final bool isHomeTeam;

  const FootballStarters({
    super.key,
    required this.starters,
    required this.isHomeTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.sizeOf(context).width * 1,
      height: MediaQuery.sizeOf(context).height * 1,
      decoration: BoxDecoration(
        // Add background image
        image: const DecorationImage(
          image: AssetImage('assets/images/court.png'),
          fit: BoxFit.fill,
          // colorFilter: ColorFilter.mode(
          //   TColors.primary.withOpacity(0.5),
          //   BlendMode.darken,
          // ),
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(children: [Text('Starters')]),
    );
  }
}
