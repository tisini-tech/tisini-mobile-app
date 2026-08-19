import 'dart:io' show Platform;

import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:flutter/foundation.dart';

enum CaptureDndResult {
  /// DND is active (no interruptions).
  enabled,

  /// Android only — user must grant notification policy access in system settings.
  policyAccessRequired,

  /// Access granted but the system did not switch to total silence.
  failedToEnable,

  /// Not supported on this platform (iOS/web).
  unsupported,
}

/// Silences Android notifications during match capture; no-op on iOS/web.
class CaptureDndService {
  CaptureDndService._();

  static final CaptureDndService instance = CaptureDndService._();

  final DoNotDisturbPlugin _dnd = DoNotDisturbPlugin();

  InterruptionFilter? _previousFilter;
  bool _enabledByApp = false;
  bool _waitingForPolicyAccess = false;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  bool get isWaitingForPolicyAccess => _waitingForPolicyAccess;

  bool get isEnabledByApp => _enabledByApp;

  /// Enables DND (no interruptions).
  Future<CaptureDndResult> enableForCapture() async {
    if (!isSupported) return CaptureDndResult.unsupported;

    try {
      final hasAccess = await _dnd.isNotificationPolicyAccessGranted();
      if (!hasAccess) {
        _waitingForPolicyAccess = true;
        _enabledByApp = false;
        return CaptureDndResult.policyAccessRequired;
      }

      _waitingForPolicyAccess = false;
      _previousFilter ??= await _dnd.getDNDStatus();
      await _dnd.setInterruptionFilter(InterruptionFilter.none);

      final current = await _dnd.getDNDStatus();
      if (current != InterruptionFilter.none) {
        _enabledByApp = false;
        return CaptureDndResult.failedToEnable;
      }

      _enabledByApp = true;
      return CaptureDndResult.enabled;
    } catch (_) {
      _enabledByApp = false;
      return CaptureDndResult.failedToEnable;
    }
  }

  /// Restores the filter that was active before capture.
  Future<void> disableForCapture() async {
    if (!isSupported || !_enabledByApp) return;

    try {
      final previous = _previousFilter;
      if (previous != null && previous != InterruptionFilter.unknown) {
        await _dnd.setInterruptionFilter(previous);
      } else {
        await _dnd.setInterruptionFilter(InterruptionFilter.all);
      }
    } catch (_) {
      // Best effort — don't block leaving match capture.
    } finally {
      _enabledByApp = false;
      _previousFilter = null;
      _waitingForPolicyAccess = false;
    }
  }

  Future<void> openPolicyAccessSettings() async {
    if (!isSupported) return;
    _waitingForPolicyAccess = true;
    await _dnd.openNotificationPolicyAccessSettings();
  }
}
