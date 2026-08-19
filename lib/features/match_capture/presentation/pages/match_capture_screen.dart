import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/services/capture_dnd_service.dart';
import 'package:tisini/features/match_capture/presentation/widgets/focus_mode_dialog.dart';
import 'package:tisini/features/match_capture/presentation/widgets/player_capture.dart';
import 'package:tisini/features/match_capture/presentation/widgets/stats_appbar.dart';
import 'package:tisini/features/match_capture/presentation/widgets/team_capture.dart';

class MatchCaptureScreen extends StatefulWidget {
  const MatchCaptureScreen({super.key});

  @override
  State<MatchCaptureScreen> createState() => _MatchCaptureScreenState();
}

class _MatchCaptureScreenState extends State<MatchCaptureScreen>
    with WidgetsBindingObserver {
  bool _active = true;
  bool _promptVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enableDnd());
  }

  Future<void> _enableDnd({bool offerPrompt = true}) async {
    if (!_active || !mounted || !CaptureDndService.instance.isSupported) {
      return;
    }

    final wasWaiting = CaptureDndService.instance.isWaitingForPolicyAccess;
    final result = await CaptureDndService.instance.enableForCapture();
    if (!_active || !mounted) return;

    switch (result) {
      case CaptureDndResult.enabled:
        if (wasWaiting) {
          showSnackbar(
            'Focus mode',
            'Notifications are silenced for this match.',
            TColors.success,
            duration: 2,
          );
        }
      case CaptureDndResult.unsupported:
        break;
      case CaptureDndResult.policyAccessRequired:
        if (offerPrompt) {
          await _showAccessPrompt();
        }
      case CaptureDndResult.failedToEnable:
        if (offerPrompt) {
          await _showAccessPrompt(failedToEnable: true);
        }
    }
  }

  Future<void> _showAccessPrompt({bool failedToEnable = false}) async {
    if (!_active || !mounted || _promptVisible) return;

    _promptVisible = true;
    try {
      await showFocusModeAccessDialog(
        context,
        failedToEnable: failedToEnable,
        onOpenSettings: CaptureDndService.instance.openPolicyAccessSettings,
      );
    } finally {
      _promptVisible = false;
    }
  }

  @override
  void dispose() {
    _active = false;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(CaptureDndService.instance.disableForCapture());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _active && mounted) {
      final shouldPrompt =
          CaptureDndService.instance.isWaitingForPolicyAccess ||
          !CaptureDndService.instance.isEnabledByApp;
      unawaited(_enableDnd(offerPrompt: shouldPrompt));
    }
  }

  @override
  Widget build(BuildContext context) => const _MatchCaptureBody();
}

class _MatchCaptureBody extends GetView<MatchCaptureController> {
  const _MatchCaptureBody();

  @override
  Widget build(BuildContext context) {
    final _ = controller;

    return Scaffold(
      appBar: StatsAppbar(),
      body: Obx(() {
        final isLoading = controller.isLoadingEvents.value;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isTeamCaptureView.value) {
          return TeamCapture();
        } else {
          return PlayerCapture();
        }
      }),
    );
  }
}
