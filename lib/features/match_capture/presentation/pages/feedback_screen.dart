import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/presentation/controllers/feedback_controller.dart';

class FeedbackScreen extends GetView<FeedbackController> {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match feedback'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          key: ValueKey(controller.formKey.value),
          children: [
              const SizedBox(height: 8),
              Text(
                'Man of the match',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                onChanged: controller.setManOfMatch,
                decoration: InputDecoration(
                hintText: 'Player name or shirt number',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: TColors.lightContainer,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Changes to be applied to the match',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              onChanged: controller.setChangesToApply,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe any corrections (goals, cards, subs, etc.)',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: TColors.lightContainer,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => CheckboxListTile(
              value: controller.confirmedCardsAndGoals.value,
              onChanged: (v) => controller.setConfirmedCardsAndGoals(v ?? false),
              title: Text(
                'I have confirmed cards and goals with the team',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TColors.textPrimary,
                ),
              ),
              activeColor: TColors.primary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            )),
            const SizedBox(height: 20),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              onChanged: controller.setComments,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any additional comments...',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: TColors.lightContainer,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: controller.isSubmitting.value ? null : controller.submitFeedback,
              style: FilledButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TColors.textWhite,
                      ),
                    )
                  : const Text('Submit feedback'),
            ),
          ],
        )),
      ),
    );
  }
}
