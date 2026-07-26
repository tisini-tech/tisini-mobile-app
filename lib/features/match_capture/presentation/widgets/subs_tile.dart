import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_tap_shell.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';

class SubsTile extends GetView<MatchCaptureController> {
  final Lineup player;

  const SubsTile({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isHomeTeam = controller.isHomeTeam;
      final selectedSub = controller.selectedSubPlayer.value?.id == player.id;

      return CaptureTapShell(
        key: ValueKey('sub_tap_${player.id}'),
        onTap: () => controller.selectSubPlayer(player),
        builder: (context, flashing) {
          final highlighted = selectedSub || flashing;

          return LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 56,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSubsJersey(
                        isHomeTeam: isHomeTeam,
                        highlighted: highlighted,
                        jerseyNo: player.jerseyNumber.toString(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        player.player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: CaptureTheme.subsNameStyle(
                          isSelected: highlighted,
                          isHomeTeam: isHomeTeam,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildSubsJersey({
    required bool isHomeTeam,
    required bool highlighted,
    required String jerseyNo,
  }) {
    final label = Center(
      child: Text(
        jerseyNo,
        style: TextStyle(
          fontSize: CaptureTheme.subsJerseyFontSize,
          fontWeight: FontWeight.w800,
          color: highlighted
              ? CaptureTheme.selectedText
              : CaptureTheme.teamLabel(isHomeTeam),
        ),
      ),
    );

    if (highlighted) {
      return Container(
        width: 56,
        height: CaptureTheme.subsBarJerseyHeight,
        decoration: CaptureTheme.playerTileDecoration(
          isHomeTeam: isHomeTeam,
          isSelected: true,
        ),
        child: label,
      );
    }

    return Container(
      width: 56,
      height: CaptureTheme.subsBarJerseyHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CaptureTheme.subsBenchBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: CaptureTheme.mirroredAccentRow(
          isHomeTeam: isHomeTeam,
          accentColor: CaptureTheme.teamAccent(isHomeTeam),
          radius: 8,
          content: label,
        ),
      ),
    );
  }
}
