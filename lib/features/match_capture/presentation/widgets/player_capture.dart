import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/domain/entities/formation.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/widgets/formation_grid.dart';
import 'package:tisini/features/match_capture/presentation/widgets/subs_tile.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_tap_shell.dart';
import 'package:tisini/features/match_capture/presentation/widgets/extended_team_capture.dart';

int _formationLinearIndex(List<int> columnsPerRow, int row, int col) {
  var index = 0;
  for (var r = 0; r < row; r++) {
    index += columnsPerRow[r];
  }
  return index + col;
}

class PlayerCapture extends GetView<MatchCaptureController> {
  const PlayerCapture({super.key});

  static int _positionAt(Formation? formation, int linearIndex) {
    return formation?.displayPositionAt(linearIndex) ?? (linearIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isHomeTeam = controller.isHomeTeam;
      final lineup = isHomeTeam ? controller.homeLineup : controller.awayLineup;
      // Rebuild when lineup data or active starters/subs change (not just squad size).
      final _ = (
        controller.lineupRevision.value,
        controller.starters.length,
        controller.subs.length,
        lineup.length,
      );

      if (lineup.isEmpty) {
        return const ExtendedTeamCapture();
      }

      return _playersView(context, controller, isHomeTeam: isHomeTeam);
    });
  }

  Widget _playersView(
    BuildContext context,
    MatchCaptureController controller, {
    required bool isHomeTeam,
  }) {
    controller.getStartersAndSubs(isHomeTeam: isHomeTeam);

    final starters = controller.starters;
    final subs = controller.subs;
    final Formation? formation = controller.selectedFormation;

    return Column(
      children: [
        // Subs section
        Card(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.11,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isHomeTeam) _subsLabel(isHomeTeam),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: subs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return SubsTile(player: subs[index]);
                      },
                    ),
                  ),
                ),
                if (!isHomeTeam) _subsLabel(isHomeTeam),
              ],
            ),
          ),
        ),
        Obx(() {
          if (!controller.isReorderMode.value) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Material(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.reorderSourcePlayer.value == null
                            ? 'Tap two starters to swap positions'
                            : 'Tap another starter to swap',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.cancelReorderMode,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Starters section (takes remaining height below subs)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: CaptureTheme.pitchTint,
                image:
                    controller.pitchBgImage != null &&
                        controller.pitchBgImage!.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(controller.pitchBgImage!),
                        fit: BoxFit.fill,
                        colorFilter: ColorFilter.mode(
                          CaptureTheme.pitchTint.withValues(alpha: 0.55),
                          BlendMode.modulate,
                        ),
                      )
                    : null,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: formation == null || formation.columnsPerRow.isEmpty
                  ? const Center(child: Text('No formation selected'))
                  : FormationGrid(
                      columnsPerRow: formation.columnsPerRow,
                      rowSpacing: 8,
                      colSpacing: 8,
                      cellBuilder: (context, row, col) {
                        final linearIndex = _formationLinearIndex(
                          formation.columnsPerRow,
                          row,
                          col,
                        );
                        final targetPosition = _positionAt(
                          formation,
                          linearIndex,
                        ).toString();
                        final positionIndex = starters.indexWhere(
                          (p) => p.lineupPosition.toString() == targetPosition,
                        );
                        if (positionIndex >= 0) {
                          return _buildPlayerTile(
                            context,
                            controller,
                            starters[positionIndex],
                            isHomeTeam,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerTile(
    BuildContext context,
    MatchCaptureController controller,
    Lineup player,
    bool isHomeTeam,
  ) {
    return Obx(() {
      final isReorder = controller.isReorderMode.value;
      final isSelected = isReorder && controller.isReorderSource(player);
      final isGk = player.isGoalkeeper;

      return CaptureTapShell(
        key: ValueKey('player_tap_${player.id}'),
        onLongPress: isReorder
            ? null
            : () {
                controller.openEventsScreen(
                  isHomeTeam: isHomeTeam,
                  player: player,
                );
              },
        onTap: () {
          if (isReorder) {
            controller.onReorderPlayerTap(player, isHomeTeam: isHomeTeam);
            return;
          }

          controller.selectStarterPlayer(player);

          final hasSubSelected = controller.selectedSubPlayer.value != null;
          if (hasSubSelected) {
            controller.setSubstitutionEvent();
            controller.submitMetric(isHomeTeam: isHomeTeam);
          } else {
            controller.selectEvent(
              controller.teamEvents.firstWhere(
                (event) => [
                  7,
                  70,
                  82,
                  91,
                  182,
                  183,
                  241,
                ].contains(event.id),
              ),
            );
            controller.submitMetric(isHomeTeam: isHomeTeam);
          }
        },
        builder: (context, flashing) {
          final highlighted = isSelected || flashing;

          return SizedBox.expand(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildJerseyTile(
                      isHomeTeam: isHomeTeam,
                      highlighted: highlighted,
                      isGk: isGk,
                      jerseyNo: player.jerseyNumber.toString(),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 96,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: CaptureTheme.playerNameChipDecoration(
                        isHomeTeam: isHomeTeam,
                      ),
                      child: Text(
                        player.player.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: CaptureTheme.playerNameStyle(
                          isSelected: highlighted,
                          isHomeTeam: isHomeTeam,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _subsLabel(bool isHomeTeam) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: CaptureTheme.teamAccent(isHomeTeam),
        borderRadius: isHomeTeam
            ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            'SUBS',
            style: const TextStyle(
              color: CaptureTheme.selectedText,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJerseyTile({
    required bool isHomeTeam,
    required bool highlighted,
    required bool isGk,
    required String jerseyNo,
  }) {
    final tileBody = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          jerseyNo,
          style: CaptureTheme.playerJerseyStyle(
            isSelected: highlighted,
            isHomeTeam: isHomeTeam,
          ),
        ),
        if (isGk) ...[
          const SizedBox(height: 2),
          Text(
            'GK',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: highlighted
                  ? CaptureTheme.selectedText
                  : CaptureTheme.goalkeepingText,
            ),
          ),
        ],
      ],
    );

    if (highlighted) {
      return Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: CaptureTheme.playerTileDecoration(
          isHomeTeam: isHomeTeam,
          isSelected: true,
          isGoalkeeper: isGk,
        ),
        child: tileBody,
      );
    }

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: CaptureTheme.playerTileDecoration(
        isHomeTeam: isHomeTeam,
        isSelected: false,
        isGoalkeeper: isGk,
      ),
      child: tileBody,
    );
  }
}
