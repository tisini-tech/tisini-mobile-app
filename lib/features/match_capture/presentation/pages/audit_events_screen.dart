import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/domain/entities/match_event.dart';
import 'package:tisini/features/match_capture/presentation/controllers/audit_events_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';

class AuditEventsScreen extends GetView<AuditEventsController> {
  const AuditEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaptureTheme.sheetBackground,
      appBar: AppBar(
        title: const Text('Match Events'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadMatchEvents,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() {
            final selected = controller.selectedTab.value;
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: SegmentedButton<AuditEventsTab>(
                segments: const [
                  ButtonSegment(
                    value: AuditEventsTab.lastTen,
                    label: Text('Last 10'),
                    icon: Icon(Icons.history, size: 18),
                  ),
                  ButtonSegment(
                    value: AuditEventsTab.critical,
                    label: Text('Audit'),
                    icon: Icon(Icons.fact_check_outlined, size: 18),
                  ),
                ],
                selected: {selected},
                onSelectionChanged: (values) {
                  controller.selectTab(values.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.events.isEmpty) {
          return _EmptyState(
            message: controller.errorMessage.value,
            onRetry: controller.loadMatchEvents,
          );
        }

        if (controller.events.isEmpty) {
          final emptyMessage =
              controller.selectedTab.value == AuditEventsTab.lastTen
              ? 'No recent events yet'
              : 'No audit events yet';
          return _EmptyState(message: emptyMessage);
        }

        return RefreshIndicator(
          onRefresh: controller.loadMatchEvents,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: controller.events.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final event = controller.events[index];
              return _AuditEventTile(
                event: event,
                onEdit: () => controller.onEditEvent(event),
                onDelete: () => _confirmDelete(context, event),
              );
            },
          ),
        );
      }),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MatchEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _DeleteEventDialog(event: event),
    );
    if (confirmed == true) {
      await controller.deleteEvent(event);
    }
  }
}

class _DeleteEventDialog extends StatelessWidget {
  const _DeleteEventDialog({required this.event});

  final MatchEvent event;

  @override
  Widget build(BuildContext context) {
    final time =
        '${event.minute}:${event.second.toString().padLeft(2, '0')}';
    final player = event.player?.name.trim();
    final detail = event.metricDetail?.name.trim();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: CaptureTheme.sheetBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CaptureTheme.awayTileFill.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 28,
                color: CaptureTheme.awayTileFill,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete this event?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CaptureTheme.surfaceText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This removes it from the match and cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.metric.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: CaptureTheme.surfaceText,
                    ),
                  ),
                  if (detail != null && detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF546E7A),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (player != null && player.isNotEmpty)
                        _DialogMetaChip(
                          icon: Icons.person_outline,
                          label: player,
                        ),
                      _DialogMetaChip(
                        icon: Icons.timer_outlined,
                        label: time,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: CaptureTheme.awayTileFill,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogMetaChip extends StatelessWidget {
  const _DialogMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF546E7A)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditEventTile extends StatelessWidget {
  const _AuditEventTile({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final MatchEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final detail = event.metricDetail?.name.trim();
    final subDetail = event.metricSubDetail?.name.trim();
    final player = event.player?.name.trim();
    final subplayer = event.subplayer?.name.trim();
    final time =
        '${event.minute}:${event.second.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.metric.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: CaptureTheme.surfaceText,
                    ),
                  ),
                  if (detail != null && detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF455A64),
                      ),
                    ),
                  ],
                  if (subDetail != null && subDetail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subDetail,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF607D8B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (player != null && player.isNotEmpty)
                        _MetaChip(
                          icon: Icons.person_outline,
                          label: subplayer != null && subplayer.isNotEmpty
                              ? 'Out: $player'
                              : player,
                        ),
                      if (subplayer != null && subplayer.isNotEmpty)
                        _MetaChip(
                          icon: Icons.swap_horiz,
                          label: 'In: $subplayer',
                        ),
                      _MetaChip(icon: Icons.timer_outlined, label: time),
                      _MetaChip(
                        icon: Icons.flag_outlined,
                        label: _formatMoment(event.moment),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: CaptureTheme.possessionBg,
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: CaptureTheme.awayTileFill,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatMoment(String moment) {
    final normalized = moment.trim().toLowerCase();
    return switch (normalized) {
      'firsthalf' || '1sthalf' => '1st Half',
      'secondhalf' || '2ndhalf' => '2nd Half',
      'extratime' || 'et' => 'Extra Time',
      'penalties' => 'Penalties',
      '' => '—',
      _ => moment,
    };
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF546E7A)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_note_outlined,
              size: 48,
              color: Color(0xFF90A4AE),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CaptureTheme.surfaceText,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
