import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/container/container_header.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/fixtures/presentation/controllers/agent_fixture_controller.dart';
import 'package:tisini/features/fixtures/presentation/widgets/fixture_match_header.dart';
import 'package:tisini/features/fixtures/presentation/widgets/fixture_option_button.dart';

class FixtureOptionsScreen extends GetView<AgentFixtureController> {
  const FixtureOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fixture = controller.selectedFixture.value;

      if (fixture == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Fixture options')),
          body: const Center(child: Text('No fixture selected.')),
        );
      }

      return _FixtureOptionsBody(fixture: fixture);
    });
  }
}

class _FixtureOptionsBody extends GetView<AgentFixtureController> {
  const _FixtureOptionsBody({required this.fixture});

  final AgentFixture fixture;

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.sizeOf(context).height * 0.25;

    return Scaffold(
      backgroundColor: TColors.softGrey,
      body: Column(
        children: [
          SizedBox(
            height: headerHeight,
            child: ContainerHeader(
              height: headerHeight,
              child: FixtureMatchHeader(
                fixture: fixture,
                title: 'Match options',
                onBack: Get.back,
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Obx(() {
                // Read list length so Obx rebuilds when local storage updates.
                final _ = controller.localEvents.length;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: _OptionsBody(
                    fixture: fixture,
                    syncedEvents: controller.syncedEvents,
                    totalEvents: controller.totalEvents,
                    pendingEvents: controller.pendingEvents,
                    isSyncing: controller.isSyncing.value,
                    onDeactivate: _confirmDeactivateMatch,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivateMatch() {
    Get.dialog(
      AlertDialog(
        title: const Text('Deactivate match'),
        content: const Text('Are you sure you want to deactivate this match?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // close confirmation dialog
              await controller.deactivateMatch();
            },
            child: const Text(
              'Deactivate',
              style: TextStyle(color: TColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsBody extends GetView<AgentFixtureController> {
  const _OptionsBody({
    required this.fixture,
    required this.syncedEvents,
    required this.totalEvents,
    required this.pendingEvents,
    required this.isSyncing,
    required this.onDeactivate,
  });

  final AgentFixture fixture;
  final int syncedEvents;
  final int totalEvents;
  final int pendingEvents;
  final bool isSyncing;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FixtureOptionSection(
          title: 'Setup',
          children: [
            FixtureOptionButton(
              icon: Icons.photo_camera_outlined,
              label: 'Pitch arrival',
              subtitle: 'Pitch photo and GPS check-in',
              onPressed: controller.goToPitchArrivalScreen,
            ),
            const SizedBox(height: 8),
            FixtureOptionButton(
              icon: Icons.people_alt_outlined,
              label: 'Match officials',
              style: FixtureOptionStyle.secondary,
              onPressed: controller.goToMatchOfficialsScreen,
            ),
            const SizedBox(height: 8),
            FixtureOptionButton(
              icon: Icons.groups_outlined,
              label: '${fixture.team1Name} lineup',
              onPressed: () => controller.goToSelectLineupsScreen({
                'id': fixture.team1Id.toString(),
                'name': fixture.team1Name,
              }),
            ),
            const SizedBox(height: 8),
            FixtureOptionButton(
              icon: Icons.groups_outlined,
              label: '${fixture.team2Name} lineup',
              onPressed: () => controller.goToSelectLineupsScreen({
                'id': fixture.team2Id.toString(),
                'name': fixture.team2Name,
              }),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FixtureOptionSection(
          title: 'During match',
          children: [
            FixtureOptionButton(
              icon: Icons.analytics_outlined,
              label: 'Team stats',
              subtitle: 'Live event totals and breakdowns',
              onPressed: controller.goToTeamStatsScreen,
            ),
            const SizedBox(height: 8),
            FixtureOptionButton(
              icon: Icons.fact_check_outlined,
              label: 'SOP',
              subtitle: 'Lineup photos, referee data, corrections',
              style: FixtureOptionStyle.info,
              onPressed: controller.goToSopScreen,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FixtureOptionButton(
                    icon: Icons.cloud_done_outlined,
                    label: '$syncedEvents / $totalEvents',
                    subtitle: 'Online / Local events',
                    style: FixtureOptionStyle.secondary,
                    showChevron: false,
                    onPressed: () {},
                  ),
                ),
                if (pendingEvents > 0) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FixtureOptionButton(
                      icon: isSyncing ? Icons.hourglass_top : Icons.sync,
                      label: isSyncing ? 'Syncing…' : 'Sync data',
                      subtitle: '$pendingEvents pending',
                      style: FixtureOptionStyle.secondary,
                      onPressed: isSyncing ? () {} : controller.syncEvents,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            FixtureOptionButton(
              icon: Icons.power_settings_new,
              label: 'Deactivate match',
              style: FixtureOptionStyle.danger,
              onPressed: onDeactivate,
            ),
          ],
        ),
        const SizedBox(height: 20),
        FixtureOptionButton(
          icon: Icons.play_arrow_rounded,
          label: 'Go to match',
          subtitle: 'Open live capture',
          style: FixtureOptionStyle.success,
          onPressed: controller.goToMatchCaptureScreen,
        ),
      ],
    );
  }
}
