import 'dart:io' show Platform;

import 'package:do_not_disturb/do_not_disturb.dart';
import 'package:flutter/foundation.dart';

/// Silences Android notifications during match capture; no-op on iOS/web.
class CaptureDndService {
  CaptureDndService._();

  static final CaptureDndService instance = CaptureDndService._();

  final DoNotDisturbPlugin _dnd = DoNotDisturbPlugin();

  InterruptionFilter? _previousFilter;
  bool _enabledByApp = false;
  bool _waitingForPolicyAccess = false;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWaitingForPolicyAccess => _waitingForPolicyAccess;

  /// Enables DND (no interruptions). Returns true if active.
  Future<bool> enableForCapture() async {
    if (!_isAndroid) return false;

    final hasAccess = await _dnd.isNotificationPolicyAccessGranted();
    if (!hasAccess) {
      _waitingForPolicyAccess = true;
      return false;
    }

    _waitingForPolicyAccess = false;
    _previousFilter = await _dnd.getDNDStatus();
    await _dnd.setInterruptionFilter(InterruptionFilter.none);
    _enabledByApp = true;
    return true;
  }

  /// Call after user returns from notification-policy settings.
  Future<bool> retryEnableAfterSettings() async {
    if (!_waitingForPolicyAccess && _enabledByApp) return _enabledByApp;
    return enableForCapture();
  }

  /// Restores the filter that was active before capture.
  Future<void> disableForCapture() async {
    if (!_isAndroid || !_enabledByApp) return;

    final previous = _previousFilter;
    if (previous != null && previous != InterruptionFilter.unknown) {
      await _dnd.setInterruptionFilter(previous);
    } else {
      await _dnd.setInterruptionFilter(InterruptionFilter.all);
    }

    _enabledByApp = false;
    _previousFilter = null;
    _waitingForPolicyAccess = false;
  }

  Future<void> openPolicyAccessSettings() async {
    if (!_isAndroid) return;
    _waitingForPolicyAccess = true;
    await _dnd.openNotificationPolicyAccessSettings();
  }
}
