import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/timer_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';

Future<void> showMatchOptionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final timerController = TimerController.instance;
      final matchCaptureController = timerController.matchCaptureController;

      return Obx(() {
        final isReorder = matchCaptureController.isReorderMode.value;
        final startLabel = timerController.isSecondHalf.value
            ? '2nd Half'
            : 'Start';

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
          ),
          decoration: const BoxDecoration(
            color: CaptureTheme.sheetBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0BEC5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Match Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: CaptureTheme.surfaceText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: CaptureTheme.generalBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          timerController.formattedTime.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: CaptureTheme.onDarkFill,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _OptionsSectionLabel('Match control'),
                          const SizedBox(height: 8),
                          _OptionsGrid(
                            children: [
                              _MatchOptionTile(
                                icon: Icons.play_arrow_rounded,
                                label: startLabel,
                                color: CaptureTheme.scoringBg,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  if (timerController.isSecondHalf.value) {
                                    timerController.resumeMatch();
                                  } else {
                                    timerController.startMatch();
                                  }
                                },
                              ),
                              _MatchOptionTile(
                                icon: Icons.replay_rounded,
                                label: 'Resume',
                                color: CaptureTheme.possessionBg,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  timerController.resumeMatch();
                                },
                              ),
                              _MatchOptionTile(
                                icon: Icons.pause_rounded,
                                label: 'Pause',
                                color: CaptureTheme.disciplineBg,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  timerController.pause();
                                },
                              ),
                              _MatchOptionTile(
                                icon: Icons.flag_rounded,
                                label: 'End Half',
                                color: CaptureTheme.defenseBg,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    timerController.endMatchHalf();
                                  });
                                },
                              ),
                              _MatchOptionTile(
                                icon: Icons.sports_score_rounded,
                                label: 'End Match',
                                color: CaptureTheme.awayTileFill,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    timerController.endMatch();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const _OptionsSectionLabel('Pitch tools'),
                          const SizedBox(height: 8),
                          _OptionsGrid(
                            children: [
                              _MatchOptionTile(
                                icon: isReorder
                                    ? Icons.check_circle_rounded
                                    : Icons.swap_horiz_rounded,
                                label: isReorder ? 'Done swap' : 'Swap',
                                color: isReorder
                                    ? CaptureTheme.scoringBg
                                    : CaptureTheme.setPieceBg,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  matchCaptureController.toggleReorderMode();
                                },
                              ),
                              _MatchOptionTile(
                                icon: Icons.grid_view_rounded,
                                label: 'Formation',
                                color: CaptureTheme.goalkeepingBg,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  showFormationPickerSheet(context);
                                },
                              ),
                              _MatchOptionTile(
                                icon: Icons.checklist_rounded,
                                label: 'Audit',
                                color: CaptureTheme.generalBg,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  timerController.goToAuditEvents();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}

void showFormationPickerSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: CaptureTheme.sheetBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      final c = TimerController.instance;

      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Change Formation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CaptureTheme.surfaceText,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: c.formations.length,
                itemBuilder: (context, index) {
                  final formation = c.formations[index];
                  final isSelected =
                      c.selectedFormation.value?.name == formation.name;
                  return ListTile(
                    title: Text(
                      formation.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CaptureTheme.surfaceText,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            color: CaptureTheme.possessionBg,
                          )
                        : null,
                    onTap: () {
                      c.changeFormation(formation);
                      Navigator.pop(sheetContext);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _OptionsSectionLabel extends StatelessWidget {
  const _OptionsSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF546E7A),
      ),
    );
  }
}

class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.35,
      children: children,
    );
  }
}

class _MatchOptionTile extends StatelessWidget {
  const _MatchOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: CaptureTheme.onDarkFill, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CaptureTheme.onDarkFill,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
