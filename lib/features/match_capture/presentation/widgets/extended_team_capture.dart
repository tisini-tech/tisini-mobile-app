import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/player_capture_events.dart';

/// Team-level capture shown when a side has no saved lineup.
///
/// Events are grouped by category (same layout as the full-screen events
/// sheet), but rendered inline so submitting does not pop the pitch view.
class ExtendedTeamCapture extends GetView<MatchCaptureController> {
  const ExtendedTeamCapture({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: CaptureTheme.sheetBackground,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: const CategorizedEventsView(
        closeParentAfterSubmit: false,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
