import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/shared/fixture_data/domain/entities/match_data.dart';
import 'package:tisini/shared/fixture_data/domain/entities/sub_event_data.dart';

class MatchEventStatTile extends StatelessWidget {
  const MatchEventStatTile({
    super.key,
    required this.event,
    required this.expanded,
    required this.onToggle,
  });

  final MatchData event;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final hasSubEvents = event.subEvents.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.borderSecondary),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: hasSubEvents ? onToggle : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  _countCell('${event.homeCount}', alignEnd: true),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            event.eventName,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: TColors.textPrimary,
                                ),
                          ),
                        ),
                        if (hasSubEvents) ...[
                          const SizedBox(width: 2),
                          AnimatedRotation(
                            turns: expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: TColors.primary,
                              size: 22,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _countCell('${event.awayCount}'),
                ],
              ),
            ),
          ),
          if (expanded && hasSubEvents)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              decoration: BoxDecoration(
                color: TColors.softGrey.withValues(alpha: 0.6),
                border: Border(
                  top: BorderSide(color: TColors.borderSecondary),
                ),
              ),
              child: Column(
                children: event.subEvents
                    .map((sub) => _SubEventRow(sub: sub))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _countCell(String value, {bool alignEnd = false}) {
    return SizedBox(
      width: 36,
      child: Text(
        value,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: TColors.primary,
        ),
      ),
    );
  }
}

class _SubEventRow extends StatelessWidget {
  const _SubEventRow({required this.sub});

  final SubEventData sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${sub.homeCount}',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              sub.subeventName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TColors.textSecondary,
                  ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${sub.awayCount}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
