import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_event_button.dart';
import 'package:tisini/features/match_capture/presentation/widgets/sub_events.dart';

/// After [MatchCaptureController.selectEvent], show detail picker or submit.
///
/// Set [includeSubDetailPicker] to false for flows that only need [Detail]
/// selection (e.g. pitch tap for a pass).
void presentMetricDetailsOrSubmit(
  BuildContext context, {
  required MatchCaptureController controller,
  required bool isHomeTeam,
  bool includeSubDetailPicker = true,
  VoidCallback? onAfterSubmit,
}) {
  if (controller.needsDetailPicker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SubEvents(
        controller: controller,
        isHomeTeam: isHomeTeam,
        onAfterSubmit: onAfterSubmit,
        includeSubDetailPicker: includeSubDetailPicker,
      ),
    );
    return;
  }

  if (includeSubDetailPicker && controller.needsSubDetailPicker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MetricSubDetails(
        controller: controller,
        isHomeTeam: isHomeTeam,
        onAfterSubmit: onAfterSubmit,
      ),
    );
    return;
  }

  controller.submitMetric(isHomeTeam: isHomeTeam, context: context);
  onAfterSubmit?.call();
}

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
        presentMetricDetailsOrSubmit(
          context,
          controller: controller,
          isHomeTeam: isHomeTeam,
          onAfterSubmit: closeParentAfterSubmit
              ? () => Navigator.of(context).pop()
              : null,
        );
      },
    );
  }
}
