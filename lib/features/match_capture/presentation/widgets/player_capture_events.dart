import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/match_capture/domain/entities/event_category.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/edit_player_sheet.dart';
import 'package:tisini/features/match_capture/presentation/widgets/events.dart';

/// Number of columns in the events grid.
const int _gridColumns = 3;

class PlayerCaptureEventsScreen extends StatelessWidget {
  const PlayerCaptureEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CaptureTheme.sheetBackground,
        appBar: AppBar(
          title: const Text('Match capture events'),
          centerTitle: true,
        ),
        // Full-screen route: pop back to the pitch after a submit.
        body: const CategorizedEventsView(closeParentAfterSubmit: true),
      ),
    );
  }
}

/// Team events grouped by category, laid out column-wise in a 3-column grid.
///
/// Used both as a full-screen events sheet (from a long-pressed player) and
/// inline for team capture when a side has no saved lineup.
class CategorizedEventsView extends GetView<MatchCaptureController> {
  const CategorizedEventsView({
    super.key,
    this.closeParentAfterSubmit = false,
    this.padding = const EdgeInsets.all(16),
  });

  /// Whether tapping an event should pop the current route after submitting.
  /// True for the full-screen sheet, false when embedded inline.
  final bool closeParentAfterSubmit;
  final EdgeInsets padding;

  /// Group event indices by metricCategory. Returns map: categoryId -> indices.
  static Map<String, List<int>> _groupIndicesByCategory(List<Metric> events) {
    final map = <String, List<int>>{};
    for (var i = 0; i < events.length; i++) {
      final cat = events[i].metricCategory.toString();
      map.putIfAbsent(cat, () => []).add(i);
    }
    return map;
  }

  /// Reorder [indices] so that when laid out in a grid with [_gridColumns] columns,
  /// items fill column by column (first column top to bottom, then second, then third).
  static List<int> _columnWiseOrder(List<int> indices) {
    if (indices.isEmpty) return [];
    final numRows = (indices.length + _gridColumns - 1) ~/ _gridColumns;
    return [
      for (var c = 0; c < _gridColumns; c++)
        for (var r = 0; r < numRows; r++)
          if (c * numRows + r < indices.length) indices[c * numRows + r],
    ];
  }

  static List<int> _uncategorizedIndices(
    List<Metric> events,
    List<MatchEventCategory> categories,
  ) {
    final knownIds = categories.map((c) => c.id.toString()).toSet();
    return [
      for (var i = 0; i < events.length; i++)
        if (!knownIds.contains(events[i].metricCategory.toString())) i,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final events = controller.teamEvents.toList();
      final categories = controller.matchCategories;
      final byCategory = _groupIndicesByCategory(events);
      final hasCategoryIds = events.any((e) => e.metricCategory != 0);

      if (events.isEmpty) {
        return const Center(child: Text('No events available'));
      }

      if (categories.isEmpty || !hasCategoryIds) {
        return SingleChildScrollView(
          padding: padding,
          child: _CategoryGrid(
            indices: _columnWiseOrder(
              List<int>.generate(events.length, (i) => i),
            ),
            isHomeTeam: controller.isHomeTeam,
            closeParentAfterSubmit: closeParentAfterSubmit,
          ),
        );
      }

      final uncategorized = _uncategorizedIndices(events, categories);

      return SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final category in categories) ...[
              if ((byCategory[category.id.toString()] ?? []).isNotEmpty) ...[
                _SectionHeader(label: category.name),
                const SizedBox(height: 8),
                _CategoryGrid(
                  indices: _columnWiseOrder(
                    byCategory[category.id.toString()] ?? [],
                  ),
                  isHomeTeam: controller.isHomeTeam,
                  closeParentAfterSubmit: closeParentAfterSubmit,
                ),
                const SizedBox(height: 20),
              ],
            ],

            if (uncategorized.isNotEmpty) ...[
              const _SectionHeader(label: 'Other'),
              const SizedBox(height: 8),
              _CategoryGrid(
                indices: _columnWiseOrder(uncategorized),
                isHomeTeam: controller.isHomeTeam,
                closeParentAfterSubmit: closeParentAfterSubmit,
              ),
            ],

            const SizedBox(height: 20),
            const _SectionHeader(label: 'Non metrics'),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final player = controller.playerForStatSheet;
                  if (player == null) {
                    showSnackbar(
                      'Edit player',
                      'No player selected for this sheet.',
                      Colors.red,
                    );
                    return;
                  }

                  var saved = false;
                  await showEditPlayerSheet(
                    context,
                    player: player,
                    fixtureType: controller.fixture.value?.fixtureType,
                    onSave: (edit) async {
                      saved = await controller.updateCapturedPlayer(
                        player,
                        edit,
                      );
                    },
                  );

                  // Edit sheet only pops itself; close events after a successful save.
                  if (saved && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                borderRadius: BorderRadius.circular(
                  CaptureTheme.eventBorderRadius,
                ),
                child: Ink(
                  height: CaptureTheme.minTouchHeight,
                  decoration: CaptureTheme.eventButtonDecoration(
                    background: CaptureTheme.generalBg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: CaptureTheme.generalText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Player',
                        style: CaptureTheme.eventLabelStyle(
                          color: CaptureTheme.generalText,
                          compact: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final player = controller.playerForStatSheet;
                  if (player == null) {
                    showSnackbar(
                      'Behaviour',
                      'No player selected for this sheet.',
                      Colors.red,
                    );
                    return;
                  }
                  controller.openBehaviourForm(
                    context: context,
                    isHomeTeam: controller.isHomeTeam,
                    player: player,
                  );
                },
                borderRadius: BorderRadius.circular(
                  CaptureTheme.eventBorderRadius,
                ),
                child: Ink(
                  height: CaptureTheme.minTouchHeight,
                  decoration: CaptureTheme.eventButtonDecoration(
                    background: CaptureTheme.disciplineBg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        size: 18,
                        color: CaptureTheme.disciplineText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Behaviour',
                        style: CaptureTheme.eventLabelStyle(
                          color: CaptureTheme.disciplineText,
                          compact: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: CaptureTheme.surfaceText,
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.indices,
    required this.isHomeTeam,
    required this.closeParentAfterSubmit,
  });

  final List<int> indices;
  final bool isHomeTeam;
  final bool closeParentAfterSubmit;

  @override
  Widget build(BuildContext context) {
    if (indices.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _gridColumns,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 100 / 75,
      children: [
        for (final index in indices)
          CaptureEvents(
            key: ValueKey('event_$index'),
            index: index,
            isHomeTeam: isHomeTeam,
            compact: false,
            closeParentAfterSubmit: closeParentAfterSubmit,
          ),
      ],
    );
  }
}
