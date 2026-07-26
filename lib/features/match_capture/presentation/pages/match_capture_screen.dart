import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/services/capture_dnd_service.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enableDnd());
  }

  Future<void> _enableDnd({bool offerPrompt = true}) async {
    if (!_active || !mounted) return;

    final enabled = await CaptureDndService.instance.enableForCapture();
    if (!_active || !mounted || enabled || !offerPrompt) return;

    await _showAccessPrompt();
  }

  Future<void> _showAccessPrompt() async {
    if (!_active || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Focus mode'),
        content: const Text(
          'Match capture works best without notification interruptions. '
          'On the next screen, allow Tisini to control Do Not Disturb, then return here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              CaptureDndService.instance.openPolicyAccessSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
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
      unawaited(_enableDnd(offerPrompt: false));
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
