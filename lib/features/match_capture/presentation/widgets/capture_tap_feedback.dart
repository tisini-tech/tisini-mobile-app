import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Short keyboard-like buzz on capture tile press (Android-first).
abstract final class CaptureTapFeedback {
  CaptureTapFeedback._();

  /// Some budget phones ignore pulses shorter than ~30ms.
  static const int tapDurationMs = 40;

  /// Longer pulse for deliberate actions (own goal, etc.).
  static const int longDurationMs = 140;

  static void trigger() {
    unawaited(_pulse());
  }

  /// Stronger feedback for long-press actions that commit important events.
  static void triggerLong() {
    unawaited(_longPulse());
  }

  static Future<void> _pulse() async {
    if (kIsWeb) {
      await HapticFeedback.selectionClick();
      return;
    }

    // Belt-and-braces: system haptic + motor when available.
    unawaited(HapticFeedback.selectionClick());

    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      // No hasVibrator() gate — some devices report false incorrectly.
      await Vibration.vibrate(duration: tapDurationMs, amplitude: 200);
    } catch (_) {
      try {
        await Vibration.vibrate(pattern: [0, tapDurationMs]);
      } catch (_) {
        if (kDebugMode) {
          debugPrint('CaptureTapFeedback: vibrate failed');
        }
      }
    }
  }

  static Future<void> _longPulse() async {
    if (kIsWeb) {
      await HapticFeedback.heavyImpact();
      return;
    }

    await HapticFeedback.heavyImpact();

    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      await Vibration.vibrate(duration: longDurationMs, amplitude: 255);
    } catch (_) {
      try {
        // Double bump so it reads clearly as a long-press ack.
        await Vibration.vibrate(pattern: [0, 70, 50, 90]);
      } catch (_) {
        if (kDebugMode) {
          debugPrint('CaptureTapFeedback: long vibrate failed');
        }
      }
    }
  }
}
