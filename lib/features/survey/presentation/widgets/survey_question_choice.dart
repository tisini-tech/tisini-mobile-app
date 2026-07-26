import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/survey.dart';
import 'package:tisini/features/survey/presentation/controllers/engagement_controller.dart';

class SurveyQuestionChoice extends StatelessWidget {
  const SurveyQuestionChoice({
    required this.question,
    this.delegate,
    super.key,
  });

  final Question question;
  final SurveyFormDelegate? delegate;

  SurveyFormDelegate get _delegate =>
      delegate ?? EngagementController.instance;

  @override
  Widget build(BuildContext context) {
    final ctrl = _delegate;
    final options = question.options ?? [];
    final multiple = question.multiple == true;
    final maxSelections = question.maxSelections;
    final layoutGrid = question.layout == 'grid';
    final helpText = question.helpText;

    return Obx(() {
      final selected = ctrl.getAnswerList(question.id as Object) ?? [];
      final error = ctrl.validateRequired(question);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TColors.textPrimary,
                ),
          ),
          if (question.isRequired)
            Text(
              'Required',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TColors.textSecondary,
                  ),
            ),
          if (helpText != null && helpText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              helpText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TColors.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TColors.error,
                    ),
              ),
            ),
          layoutGrid
              ? _buildGrid(
                  context, ctrl, options, selected, multiple, maxSelections)
              : _buildList(
                  context, ctrl, options, selected, multiple, maxSelections),
        ],
      );
    });
  }

  Widget _buildList(
    BuildContext context,
    SurveyFormDelegate ctrl,
    List<String> options,
    List<String> selected,
    bool multiple,
    int? maxSelections,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () =>
                _toggle(ctrl, opt, selected, multiple, maxSelections),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? TColors.primary.withValues(alpha: 0.12)
                    : TColors.lightContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isSelected ? TColors.primary : TColors.borderSecondary,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    multiple
                        ? (isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank)
                        : (isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off),
                    color:
                        isSelected ? TColors.primary : TColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opt,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    SurveyFormDelegate ctrl,
    List<String> options,
    List<String> selected,
    bool multiple,
    int? maxSelections,
  ) {
    const crossAxisCount = 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return InkWell(
          onTap: () =>
              _toggle(ctrl, opt, selected, multiple, maxSelections),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? TColors.primary.withValues(alpha: 0.12)
                  : TColors.lightContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? TColors.primary : TColors.borderSecondary,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  multiple
                      ? (isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank)
                      : (isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off),
                  color: isSelected ? TColors.primary : TColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    opt,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggle(
    SurveyFormDelegate ctrl,
    String opt,
    List<String> selected,
    bool multiple,
    int? maxSelections,
  ) {
    if (multiple) {
      final next = List<String>.from(selected);
      if (next.contains(opt)) {
        next.remove(opt);
      } else {
        if (maxSelections != null && next.length >= maxSelections) return;
        next.add(opt);
      }
      ctrl.setAnswer(question.id, next);
    } else {
      ctrl.setAnswer(question.id, opt);
    }
  }
}
