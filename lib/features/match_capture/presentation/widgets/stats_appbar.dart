import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/match_capture/presentation/controllers/timer_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_tap_feedback.dart';
import 'package:tisini/features/match_capture/presentation/widgets/fixture_event_stats_row.dart';
import 'package:tisini/features/match_capture/presentation/widgets/match_options_sheet.dart';

class StatsAppbar extends GetView<TimerController>
    implements PreferredSizeWidget {
  const StatsAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fixture = controller.fixture;
      // Rebuild when live scores from /fixture-scores update
      final _ = controller.matchCaptureController.matchScore.value;

      return AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 200,
        titleSpacing: 10,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTeamCard(
                    context,
                    fixture.team1Id.toString(),
                    fixture: fixture,
                  ),
                ),
                Expanded(flex: 1, child: _buildTeamTime(context)),
                Expanded(
                  flex: 2,
                  child: _buildTeamCard(
                    context,
                    fixture.team2Id.toString(),
                    fixture: fixture,
                    away: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const FixtureEventStatsRow(),
          ],
        ),
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(200);

  Widget _buildTeamCard(
    BuildContext context,
    String teamId, {
    required AgentFixture fixture,
    bool away = false,
  }) {
    final score = controller.getScores(teamId).toString();

    final teamName = fixture.team1Id.toString() == teamId
        ? fixture.team1Name
        : fixture.team2Name;

    return GestureDetector(
      onTap: () => controller.toggleTeam(),
      onLongPress: () {
        CaptureTapFeedback.triggerLong();
        controller.submitOwnGoal(isHomeTeam: !away, context: context);
      },
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 0,
          color: CaptureTheme.teamTileFill(!away),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: CaptureTheme.mirroredAccentRow(
                isHomeTeam: !away,
                accentColor: CaptureTheme.teamAccent(!away),
                accentWidth: 6,
                radius: 12,
                content: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          teamName.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: CaptureTheme.teamText(!away),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        score,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: CaptureTheme.teamText(!away),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTime(BuildContext context) {
    return Obx(() {
      final timer = TimerController.instance;

      return Column(
        children: [
          TextButton.icon(
            onPressed: () => showMatchOptionsSheet(context),
            label: const Icon(Icons.timer, color: TColors.textWhite, size: 30),
          ),
          Text(
            timer.formattedTime.value,
            style: const TextStyle(fontSize: 18, color: TColors.secondary),
          ),
        ],
      );
    });
  }
}
