import 'package:flutter/material.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_tap_feedback.dart';

/// Instant tap ack for capture tiles: vibrate + brief flash (every tap fires).
class CaptureTapShell extends StatefulWidget {
  const CaptureTapShell({
    super.key,
    required this.onTap,
    required this.builder,
    this.onLongPress,
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget Function(BuildContext context, bool flashing) builder;

  static const Duration flashDuration = Duration(milliseconds: 180);

  @override
  State<CaptureTapShell> createState() => _CaptureTapShellState();
}

class _CaptureTapShellState extends State<CaptureTapShell> {
  bool _flashing = false;

  void _handleTapDown(TapDownDetails details) {
    CaptureTapFeedback.trigger();
  }

  void _handleTap() {
    setState(() => _flashing = true);

    // Run action after the flash so GetX rebuilds don't cancel it before paint.
    Future<void>.delayed(CaptureTapShell.flashDuration, () {
      if (!mounted) return;
      setState(() => _flashing = false);
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: widget.builder(context, _flashing),
    );
  }
}
