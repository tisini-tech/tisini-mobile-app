import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/controllers/timer_controller.dart';
import 'package:tisini/features/match_capture/presentation/widgets/match_options_sheet.dart';

enum MatchRecordingBlock { none, notStarted, halfTime, fullTime }

enum MatchRecordingDialogAction { dismiss, openClock }

extension MatchRecordingBlockMessages on MatchRecordingBlock {
  String get title {
    switch (this) {
      case MatchRecordingBlock.notStarted:
        return 'Start the match first';
      case MatchRecordingBlock.halfTime:
        return 'Half time break';
      case MatchRecordingBlock.fullTime:
        return 'Match finished';
      case MatchRecordingBlock.none:
        return '';
    }
  }

  String get message {
    switch (this) {
      case MatchRecordingBlock.notStarted:
        return 'Record stats only after you start the first or second half '
            'from the match clock.';
      case MatchRecordingBlock.halfTime:
        return 'Recording is paused at half time. Start the second half '
            'from the match clock to continue.';
      case MatchRecordingBlock.fullTime:
        return 'This match has ended. You can no longer record new stats.';
      case MatchRecordingBlock.none:
        return '';
    }
  }

  IconData get icon {
    switch (this) {
      case MatchRecordingBlock.notStarted:
        return Icons.timer_outlined;
      case MatchRecordingBlock.halfTime:
        return Icons.sports_soccer_outlined;
      case MatchRecordingBlock.fullTime:
        return Icons.flag_outlined;
      case MatchRecordingBlock.none:
        return Icons.info_outline;
    }
  }

  bool get canOpenClock =>
      this == MatchRecordingBlock.notStarted ||
      this == MatchRecordingBlock.halfTime;
}

/// Persistent hint while recording is blocked (pre-match, HT, or FT).
class MatchRecordingBanner extends StatelessWidget {
  const MatchRecordingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = TimerController.instance;

    return Obx(() {
      final block = timer.recordingBlock;
      // Ensure rebuild when clock or half changes.
      final _ = (
        timer.isRunning.value,
        timer.isSecondHalf.value,
      );
      if (block == MatchRecordingBlock.none) {
        return const SizedBox.shrink();
      }

      final canOpen = block.canOpenClock;

      return Material(
        color: _bannerColor(block),
        elevation: 0,
        child: InkWell(
          onTap: canOpen ? () => showMatchOptionsSheet(context) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(block.icon, color: _bannerIconColor(block), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        block.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _bannerTextColor(block),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        block.message,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.25,
                          color: _bannerTextColor(block).withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canOpen) ...[
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => showMatchOptionsSheet(context),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Clock'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Color _bannerColor(MatchRecordingBlock block) {
    switch (block) {
      case MatchRecordingBlock.fullTime:
        return TColors.error.withValues(alpha: 0.12);
      case MatchRecordingBlock.halfTime:
        return Colors.amber.shade100;
      case MatchRecordingBlock.notStarted:
        return TColors.primary.withValues(alpha: 0.1);
      case MatchRecordingBlock.none:
        return Colors.transparent;
    }
  }

  Color _bannerTextColor(MatchRecordingBlock block) {
    switch (block) {
      case MatchRecordingBlock.fullTime:
        return TColors.error;
      case MatchRecordingBlock.halfTime:
        return const Color(0xFFE65100);
      case MatchRecordingBlock.notStarted:
        return TColors.primary;
      case MatchRecordingBlock.none:
        return TColors.textPrimary;
    }
  }

  Color _bannerIconColor(MatchRecordingBlock block) => _bannerTextColor(block);
}

Future<MatchRecordingDialogAction?> showMatchRecordingRequiredDialog({
  required BuildContext context,
  required MatchRecordingBlock block,
}) {
  return showDialog<MatchRecordingDialogAction>(
    context: context,
    builder: (dialogContext) {
      final canOpen = block.canOpenClock;

      return AlertDialog(
        icon: Icon(block.icon, size: 32, color: TColors.primary),
        title: Text(block.title),
        content: Text(block.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(MatchRecordingDialogAction.dismiss),
            child: const Text('Not now'),
          ),
          if (canOpen)
            FilledButton.icon(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(MatchRecordingDialogAction.openClock),
              icon: const Icon(Icons.timer_outlined, size: 20),
              label: const Text('Open match clock'),
            ),
        ],
      );
    },
  );
}

/// Returns `true` when the agent may record stats/events.
Future<bool> ensureMatchRecordingAllowed({
  BuildContext? context,
}) async {
  final capture = MatchCaptureController.instance;
  if (capture.canRecordEvents) return true;

  final block = capture.recordingBlock;
  final ctx = context ?? Get.context;
  if (ctx == null || !ctx.mounted) {
    return false;
  }

  final action = await showMatchRecordingRequiredDialog(
    context: ctx,
    block: block,
  );
  if (action != MatchRecordingDialogAction.openClock) return false;

  await showMatchOptionsSheet(ctx);
  return capture.canRecordEvents;
}

MatchRecordingBlock resolveRecordingBlock({
  required String gameStatus,
  required bool isRunning,
  required bool isSecondHalf,
}) {
  final status = gameStatus.trim().toLowerCase();

  if (status == 'ft') {
    return MatchRecordingBlock.fullTime;
  }

  if (status == 'ht') {
    if (isSecondHalf && isRunning) {
      return MatchRecordingBlock.none;
    }
    return MatchRecordingBlock.halfTime;
  }

  if (status == 'started') {
    return MatchRecordingBlock.none;
  }

  if (isRunning) {
    return MatchRecordingBlock.none;
  }

  return MatchRecordingBlock.notStarted;
}
