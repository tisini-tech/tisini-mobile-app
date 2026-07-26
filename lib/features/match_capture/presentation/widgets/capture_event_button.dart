import 'package:flutter/material.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_tap_shell.dart';

/// Tappable event cell tuned for outdoor readability.
class CaptureEventButton extends StatelessWidget {
  const CaptureEventButton({
    super.key,
    required this.event,
    required this.isHomeTeam,
    required this.onTap,
    this.compact = false,
  });

  final Metric event;
  final bool isHomeTeam;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = CaptureTheme.teamEventColors(isHomeTeam);

    return CaptureTapShell(
      key: ValueKey('event_tap_${event.id}_$isHomeTeam'),
      onTap: onTap,
      builder: (context, flashing) {
        final background =
            flashing ? CaptureTheme.selectedFill : colors.background;
        final textColor =
            flashing ? CaptureTheme.selectedText : colors.text;
        final accentColor =
            flashing ? CaptureTheme.selectedBorder : colors.border;

        return Material(
          color: Colors.transparent,
          child: Ink(
            decoration: CaptureTheme.eventButtonDecoration(
              background: background,
              highlighted: flashing,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: CaptureTheme.mirroredAccentRow(
                isHomeTeam: isHomeTeam,
                accentColor: accentColor,
                content: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 4 : 6,
                      vertical: compact ? 4 : 8,
                    ),
                    child: Text(
                      event.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CaptureTheme.eventLabelStyle(
                        color: textColor,
                        compact: compact,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
