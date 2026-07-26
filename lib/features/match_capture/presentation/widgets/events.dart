import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_event_button.dart';
import 'package:tisini/features/match_capture/presentation/widgets/sub_events.dart';

class CaptureEvents extends GetView<MatchCaptureController> {
  final int index;
  final bool isHomeTeam;
  final bool compact;
  final bool closeParentAfterSubmit;

  const CaptureEvents({
    super.key,
    required this.index,
    required this.isHomeTeam,
    required this.compact,
    this.closeParentAfterSubmit = false,
  });

  @override
  Widget build(BuildContext context) {
    final teamEvents = controller.teamEvents;
    final event = teamEvents[index];

    return CaptureEventButton(
      event: event,
      isHomeTeam: isHomeTeam,
      compact: compact,
      onTap: () {
        controller.selectEvent(event);
        _handleMetricTap(context, controller);
      },
    );
  }

  void _handleMetricTap(
    BuildContext context,
    MatchCaptureController controller,
  ) {
    final onAfterSubmit = closeParentAfterSubmit
        ? () => Navigator.of(context).pop()
        : null;

    if (controller.needsDetailPicker) {
      _showSheet(
        context,
        SubEvents(
          controller: controller,
          isHomeTeam: isHomeTeam,
          onAfterSubmit: onAfterSubmit,
        ),
      );
      return;
    }

    if (controller.needsSubDetailPicker) {
      _showSheet(
        context,
        MetricSubDetails(
          controller: controller,
          isHomeTeam: isHomeTeam,
          onAfterSubmit: onAfterSubmit,
        ),
      );
      return;
    }

    controller.submitMetric(isHomeTeam: isHomeTeam);
    onAfterSubmit?.call();
  }

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => sheet,
    );
  }
}
