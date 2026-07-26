import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_event_button.dart';
import 'package:tisini/features/match_capture/presentation/widgets/sub_events.dart';

class TeamCapture extends GetView<MatchCaptureController> {
  const TeamCapture({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MatchCaptureController.instance;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _buildTeamEvents(
              context,
              isHomeTeam: true,
              controller: controller,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTeamEvents(
              context,
              isHomeTeam: false,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  static const int _crossAxisCount = 2;

  Widget _buildTeamEvents(
    BuildContext context, {
    required bool isHomeTeam,
    required MatchCaptureController controller,
  }) {
    return Obx(() {
      final teamEvents = controller.teamEvents;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: CaptureTheme.teamPanelBg(isHomeTeam),
        margin: EdgeInsets.zero,
        child: teamEvents.isEmpty
            ? const Center(child: Text('No team events'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  const padding = 12.0;
                  const mainAxisSpacing = 8.0;
                  const crossAxisSpacing = 8.0;
                  final rows =
                      (teamEvents.length + _crossAxisCount - 1) ~/
                      _crossAxisCount;
                  final availableHeight = constraints.maxHeight - padding * 2;
                  final totalSpacing = mainAxisSpacing * (rows - 1);
                  final cellHeight =
                      ((availableHeight - totalSpacing) / rows).clamp(
                        CaptureTheme.minTouchHeight,
                        120.0,
                      );

                  return Padding(
                    padding: const EdgeInsets.all(padding),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                        mainAxisExtent: cellHeight,
                      ),
                      itemCount: teamEvents.length,
                      itemBuilder: (context, index) {
                        final event = teamEvents[index];
                        final compact = cellHeight < 56;

                        return CaptureEventButton(
                          event: event,
                          isHomeTeam: isHomeTeam,
                          compact: compact,
                          onTap: () {
                            controller.selectEvent(event);

                            if (controller.needsDetailPicker) {
                              _showSubEventsBottomSheet(
                                context,
                                isHomeTeam,
                                controller,
                              );
                            } else if (controller.needsSubDetailPicker) {
                              _showSubDetailsBottomSheet(
                                context,
                                isHomeTeam,
                                controller,
                              );
                            } else {
                              controller.submitMetric(isHomeTeam: isHomeTeam);
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      );
    });
  }

  void _showSubEventsBottomSheet(
    BuildContext context,
    bool isHomeTeam,
    MatchCaptureController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SubEvents(controller: controller, isHomeTeam: isHomeTeam);
      },
    );
  }

  void _showSubDetailsBottomSheet(
    BuildContext context,
    bool isHomeTeam,
    MatchCaptureController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return MetricSubDetails(
          controller: controller,
          isHomeTeam: isHomeTeam,
        );
      },
    );
  }
}
