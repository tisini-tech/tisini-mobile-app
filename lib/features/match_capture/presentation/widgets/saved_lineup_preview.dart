import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/presentation/widgets/edit_player_sheet.dart';

export 'package:tisini/features/match_capture/presentation/widgets/edit_player_sheet.dart'
    show SavedLineupPlayerEdit, splitPlayerName, showEditPlayerSheet;

/// View of a saved fixture lineup: starters ([playerType] first11) and subs.
class SavedLineupPreview extends StatelessWidget {
  const SavedLineupPreview({
    super.key,
    required this.lineup,
    this.onUpdatePlayer,
    this.onBehaviour,
    this.fixtureType,
  });

  final List<Lineup> lineup;
  final Future<void> Function(Lineup player, SavedLineupPlayerEdit edit)?
  onUpdatePlayer;
  final void Function(Lineup player)? onBehaviour;
  final String? fixtureType;

  static List<Lineup> startersFrom(List<Lineup> players) {
    final starters = players.where((p) => p.role == 'first11').toList()
      ..sort((a, b) {
        final posA = int.tryParse(a.lineupPosition.toString()) ?? 999;
        final posB = int.tryParse(b.lineupPosition.toString()) ?? 999;
        return posA.compareTo(posB);
      });
    return starters;
  }

  static List<Lineup> subsFrom(List<Lineup> players) {
    return players.where((p) => p.role == 'sub' || p.role == 'subs').toList();
  }

  @override
  Widget build(BuildContext context) {
    final starters = startersFrom(lineup);
    final subs = subsFrom(lineup);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _LineupSection(
          title: 'Starters',
          count: starters.length,
          emptyMessage: 'No starters in lineup',
          players: starters,
          showPosition: true,
          onUpdatePlayer: onUpdatePlayer,
          onBehaviour: onBehaviour,
          fixtureType: fixtureType,
        ),
        const SizedBox(height: 20),
        _LineupSection(
          title: 'Substitutes',
          count: subs.length,
          emptyMessage: 'No substitutes',
          players: subs,
          showPosition: false,
          onUpdatePlayer: onUpdatePlayer,
          onBehaviour: onBehaviour,
          fixtureType: fixtureType,
        ),
      ],
    );
  }
}

class _LineupSection extends StatelessWidget {
  const _LineupSection({
    required this.title,
    required this.count,
    required this.emptyMessage,
    required this.players,
    required this.showPosition,
    this.onUpdatePlayer,
    this.onBehaviour,
    this.fixtureType,
  });

  final String title;
  final int count;
  final String emptyMessage;
  final List<Lineup> players;
  final bool showPosition;
  final Future<void> Function(Lineup player, SavedLineupPlayerEdit edit)?
  onUpdatePlayer;
  final void Function(Lineup player)? onBehaviour;
  final String? fixtureType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$title ($count)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (players.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: TColors.lightContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TColors.borderSecondary),
            ),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: TColors.textSecondary),
            ),
          )
        else
          ...players.map(
            (player) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SavedLineupPlayerTile(
                player: player,
                showPosition: showPosition,
                onEdit: onUpdatePlayer == null
                    ? null
                    : () => showEditPlayerSheet(
                        context,
                        player: player,
                        fixtureType: fixtureType,
                        onSave: (edit) => onUpdatePlayer!(player, edit),
                      ),
                onBehaviour: onBehaviour == null
                    ? null
                    : () => onBehaviour!(player),
              ),
            ),
          ),
      ],
    );
  }
}

class _SavedLineupPlayerTile extends StatelessWidget {
  const _SavedLineupPlayerTile({
    required this.player,
    required this.showPosition,
    this.onEdit,
    this.onBehaviour,
  });

  final Lineup player;
  final bool showPosition;
  final VoidCallback? onEdit;
  final VoidCallback? onBehaviour;

  String? _formattedRating() {
    final value = player.rating?.toString().trim();
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    return number?.toStringAsFixed(1) ?? value;
  }

  @override
  Widget build(BuildContext context) {
    final jersey = player.jerseyNumber.toString().isNotEmpty
        ? player.jerseyNumber.toString()
        : '?';
    final rating = _formattedRating();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: TColors.borderSecondary),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (showPosition &&
                player.lineupPosition.toString().isNotEmpty) ...[
              SizedBox(
                width: 28,
                child: Text(
                  player.lineupPosition.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: TColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            CircleAvatar(
              radius: 20,
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
                children: [
                  Text(
                    player.player.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TColors.textPrimary,
                    ),
                  ),
                  if (player.player.currentPosition.trim().isNotEmpty)
                    Text(
                      player.player.currentPosition,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (rating != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: TColors.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  rating,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: TColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            if (onBehaviour != null) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: onBehaviour,
                tooltip: 'Record behaviour',
                icon: const Icon(Icons.psychology_outlined, size: 20),
                color: TColors.secondary,
              ),
            ],
            if (onEdit != null) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit player',
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: TColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
