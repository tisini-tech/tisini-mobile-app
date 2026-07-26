import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

enum FixtureOptionStyle { primary, secondary, danger, success, info }

class FixtureOptionButton extends StatelessWidget {
  const FixtureOptionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.style = FixtureOptionStyle.primary,
    this.subtitle,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onPressed;
  final FixtureOptionStyle style;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();

    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: colors.icon, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.label,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                Icon(Icons.chevron_right, color: colors.chevron, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  _OptionColors _resolveColors() {
    switch (style) {
      case FixtureOptionStyle.danger:
        return _OptionColors(
          background: TColors.lightContainer,
          border: TColors.error.withValues(alpha: 0.35),
          iconBackground: TColors.error.withValues(alpha: 0.12),
          icon: TColors.error,
          label: TColors.textPrimary,
          chevron: TColors.error.withValues(alpha: 0.6),
        );
      case FixtureOptionStyle.success:
        return _OptionColors(
          background: TColors.success,
          border: TColors.success,
          iconBackground: TColors.textWhite.withValues(alpha: 0.2),
          icon: TColors.textWhite,
          label: TColors.textWhite,
          chevron: TColors.textWhite.withValues(alpha: 0.85),
        );
      case FixtureOptionStyle.info:
        return _OptionColors(
          background: TColors.lightContainer,
          border: TColors.info.withValues(alpha: 0.35),
          iconBackground: TColors.info.withValues(alpha: 0.12),
          icon: TColors.info,
          label: TColors.textPrimary,
          chevron: TColors.textSecondary,
        );
      case FixtureOptionStyle.secondary:
        return _OptionColors(
          background: TColors.lightContainer,
          border: TColors.borderSecondary,
          iconBackground: TColors.accent.withValues(alpha: 0.12),
          icon: TColors.accent,
          label: TColors.textPrimary,
          chevron: TColors.textSecondary,
        );
      case FixtureOptionStyle.primary:
        return _OptionColors(
          background: TColors.lightContainer,
          border: TColors.primary.withValues(alpha: 0.25),
          iconBackground: TColors.primary.withValues(alpha: 0.12),
          icon: TColors.primary,
          label: TColors.textPrimary,
          chevron: TColors.textSecondary,
        );
    }
  }
}

class _OptionColors {
  const _OptionColors({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.icon,
    required this.label,
    required this.chevron,
  });

  final Color background;
  final Color border;
  final Color iconBackground;
  final Color icon;
  final Color label;
  final Color chevron;
}

class FixtureOptionSection extends StatelessWidget {
  const FixtureOptionSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}
