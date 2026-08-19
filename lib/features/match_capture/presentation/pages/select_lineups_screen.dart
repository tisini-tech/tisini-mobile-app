import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/domain/entities/player.dart';
import 'package:tisini/features/match_capture/presentation/controllers/lineup_controller.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/widgets/saved_lineup_preview.dart';

class SelectLineupsScreen extends GetView<LineupController> {
  const SelectLineupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${controller.team['name']} Lineups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => controller.goToAddPlayerScreen(),
            tooltip: 'Add new player',
          ),
        ],
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Derive view from data: lineup loaded → preview; no lineup → select
        final hasLineup = controller.lineup.isNotEmpty;
        if (hasLineup) {
          return SavedLineupPreview(
            lineup: controller.lineup,
            onUpdatePlayer: controller.updateSavedPlayer,
            fixtureType: controller.fixture.value?.fixtureType,
            onBehaviour: (player) {
              MatchCaptureController? mc;
              try {
                mc = Get.find<MatchCaptureController>();
              } catch (_) {
                mc = null;
              }
              if (mc == null) {
                Get.snackbar(
                  'Not available',
                  'Open the match capture screen first.',
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 3),
                );
                return;
              }
              mc.openBehaviourForm(
                context: context,
                isHomeTeam: mc.isHomeTeam,
                player: player,
                bypassGuard: true,
              );
            },
          );
        }

        final players = controller.players;
        if (players.isEmpty) {
          return Center(
            child: Text(
              'No players in this team. Add players first.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: TColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          );
        }

        return _buildLineupSelector(context);
      }),
    );
  }

  Widget _buildLineupSelector(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Starters: ${controller.starters.length}/${controller.maxStarters()} • Substitutes: ${controller.substitutes.length}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: TColors.textSecondary),
              ),

              const SizedBox(height: 12),
              Obx(
                () => TextField(
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search players by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.searchQuery.value.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: controller.clearSearch,
                          ),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final filtered = controller.filteredPlayers;
            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  controller.searchQuery.value.isEmpty
                      ? 'No players in this team.'
                      : 'No players match "${controller.searchQuery.value}".',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final player = filtered[index];
                return _buildPlayerLineupTile(context, player);
              },
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.saveLineup,
              child: controller.isSaving.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save lineups'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerLineupTile(BuildContext context, TeamPlayer teamPlayer) {
    final jersey = teamPlayer.currentJerseyNo > 0
        ? teamPlayer.currentJerseyNo.toString()
        : '?';
    final position = teamPlayer.player.currentPosition;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: TColors.primaryBackground,
              child: Text(
                jersey,
                style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    teamPlayer.player.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (position.isNotEmpty)
                    Text(
                      position,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: const Text('Starter'),
                  selected: controller.starters.any((p) => p.id == teamPlayer.id),
                  onSelected: (_) => controller.setStarter(teamPlayer),
                  selectedColor: TColors.primary,
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Sub'),
                  selected: controller.substitutes.any(
                    (p) => p.id == teamPlayer.id,
                  ),
                  onSelected: (_) => controller.setSubstitute(teamPlayer),
                  selectedColor: TColors.primary,
                ),
                if (controller.starters.any((p) => p.id == teamPlayer.id) ||
                    controller.substitutes.any((p) => p.id == teamPlayer.id))
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => controller.clearRole(teamPlayer),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
