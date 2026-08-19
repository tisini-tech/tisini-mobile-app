import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

/// Styled prompt for Android Do Not Disturb / notification policy access.
Future<void> showFocusModeAccessDialog(
  BuildContext context, {
  bool failedToEnable = false,
  required VoidCallback onOpenSettings,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !failedToEnable,
    builder: (dialogContext) => _FocusModeAccessDialog(
      failedToEnable: failedToEnable,
      onOpenSettings: () {
        Navigator.of(dialogContext).pop();
        onOpenSettings();
      },
      onDismiss: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

class _FocusModeAccessDialog extends StatelessWidget {
  const _FocusModeAccessDialog({
    required this.failedToEnable,
    required this.onOpenSettings,
    required this.onDismiss,
  });

  final bool failedToEnable;
  final VoidCallback onOpenSettings;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final title = failedToEnable
        ? 'Could not enable focus mode'
        : 'Stay focused during capture';
    final message = failedToEnable
        ? 'Tisini could not turn on Do Not Disturb. Allow notification '
              'access for Tisini in settings, then return to this match.'
        : 'Silence notifications while you capture stats so nothing '
              'pulls you out of the match.';

    final accent = failedToEnable ? TColors.warning : TColors.primary;
    final icon = failedToEnable
        ? Icons.notifications_off_outlined
        : Icons.do_not_disturb_on_total_silence_outlined;

    return Dialog(
      backgroundColor: TColors.lightContainer,
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: accent),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: TColors.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: TColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _StepsHint(failedToEnable: failedToEnable),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings_outlined, size: 20),
                label: const Text('Open settings'),
                style: FilledButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.textWhite,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: onDismiss,
              style: TextButton.styleFrom(
                foregroundColor: TColors.textSecondary,
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text(
                'Not now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsHint extends StatelessWidget {
  const _StepsHint({required this.failedToEnable});

  final bool failedToEnable;

  @override
  Widget build(BuildContext context) {
    final steps = failedToEnable
        ? const [
            'Open notification access settings',
            'Turn on Tisini',
            'Return here — focus mode applies automatically',
          ]
        : const [
            'Open settings on the next screen',
            'Allow Tisini to control Do Not Disturb',
            'Come back — notifications stay silenced for this match',
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: TColors.softGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.borderSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            failedToEnable ? 'Try this' : 'Quick setup',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _StepRow(number: i + 1, text: steps[i]),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: TColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: TColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
