import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tisini/core/constants/colors.dart';

/// Parsed display fields for a `yyyy-MM-dd` match date.
class FixtureDateChipData {
  const FixtureDateChipData({
    required this.weekday,
    required this.dayMonth,
    required this.isToday,
  });

  final String weekday;
  final String dayMonth;
  final bool isToday;

  static FixtureDateChipData fromIso(String iso) {
    final normalized = iso.length <= 10 ? '${iso}T00:00:00' : iso;
    final date = DateTime.parse(normalized);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);

    return FixtureDateChipData(
      weekday: DateFormat('EEE').format(date),
      dayMonth: DateFormat('d MMM').format(date),
      isToday: day == today,
    );
  }
}

/// Horizontal date picker used on livescores / fixtures screens.
class FixtureDatesStrip extends StatelessWidget {
  const FixtureDatesStrip({
    super.key,
    required this.dates,
    required this.selectedDate,
    this.scrollController,
    this.onDateSelected,
    this.enabled = true,
  });

  final List<String> dates;
  final String selectedDate;
  final ScrollController? scrollController;
  final ValueChanged<String>? onDateSelected;
  final bool enabled;

  static const double stripHeight = 56;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TColors.light,
        border: Border(
          bottom: BorderSide(
            color: TColors.borderSecondary.withValues(alpha: 0.9),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: stripHeight,
        child: ListView.separated(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final date = dates[index];
            return _DateChip(
              data: FixtureDateChipData.fromIso(date),
              isSelected: date == selectedDate,
              onTap: enabled && onDateSelected != null
                  ? () => onDateSelected!(date)
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.data, required this.isSelected, this.onTap});

  final FixtureDateChipData data;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minWidth: 50),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? TColors.primary : TColors.lightContainer,
            borderRadius: borderRadius,
            border: Border.all(
              color: isSelected
                  ? TColors.primary
                  : data.isToday
                  ? TColors.primary.withValues(alpha: 0.55)
                  : TColors.borderSecondary,
              width: data.isToday && !isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: TColors.primary.withValues(alpha: 0.22),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.weekday.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isSelected
                      ? TColors.textWhite.withValues(alpha: 0.8)
                      : TColors.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                data.dayMonth,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: isSelected ? TColors.textWhite : TColors.textPrimary,
                ),
              ),
              if (data.isToday) ...[
                const SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? TColors.secondary : TColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
