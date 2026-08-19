import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/survey/domain/entities/questions.dart';
import 'package:tisini/features/survey/presentation/controllers/engagement_controller.dart';

class EngagementScreen extends GetView<EngagementController> {
  const EngagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
        elevation: 0,
        title: Obx(
          () => Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  controller.surveyTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                child: Text(
                  '${controller.successResponses.value}/${controller.totalResponses.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined),
            tooltip: 'Surveyer',
            onPressed: controller.showSurveyerDialog,
          ),
          Obx(() {
            final syncing = controller.isSyncing.value;
            return IconButton(
              icon: syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TColors.textWhite,
                      ),
                    )
                  : const Icon(Icons.sync),
              onPressed: syncing ? null : controller.syncPendingResponses,
              tooltip: 'Sync offline responses',
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.survey.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final current = controller.currentQuestion;
        final total = controller.totalQuestions;
        final index = controller.currentQuestionIndex.value;
        final isFirst = controller.isFirstQuestion;
        final isLast = controller.isLastQuestion;

        if (current == null || total == 0) {
          return const Center(
            child: Text(
              'No questions in this survey',
              style: TextStyle(color: TColors.textSecondary),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1} of $total',
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: total > 0 ? (index + 1) / total : 0,
                    backgroundColor: TColors.borderSecondary,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      TColors.primary,
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _QuestionStep(
                  key: ValueKey(
                    'question_${current.id}_${index}_${controller.formVersion.value}',
                  ),
                  question: current,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.lightContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (!isFirst)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.goToPreviousQuestion,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TColors.primary,
                            side: const BorderSide(color: TColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    if (!isFirst) const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => isLast
                            ? controller.submit()
                            : controller.goToNextQuestion(),
                        style: FilledButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: TColors.textWhite,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(isLast ? 'Submit' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _QuestionStep extends GetView<EngagementController> {
  const _QuestionStep({super.key, required this.question});

  final Questions question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: question.text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
              children: [
                if (question.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: TColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          if (question.imageUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                question.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildAnswerInput(),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    switch (question.answerType) {
      case EngagementController.answerTypeSingle:
        return _SingleChoiceInput(question: question);
      case EngagementController.answerTypeMultiple:
        return _MultipleChoiceInput(question: question);
      case EngagementController.answerTypeFreeText:
        return _FreeTextInput(question: question);
      default:
        return Text(
          'Unsupported answer type: ${question.answerType}',
          style: const TextStyle(color: TColors.textSecondary),
        );
    }
  }
}

class _SingleChoiceInput extends GetView<EngagementController> {
  const _SingleChoiceInput({required this.question});

  final Questions question;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          for (final choice in question.choices)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                controller.isChoiceSelected(question, choice.id)
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: TColors.primary,
              ),
              title: Text(choice.text),
              onTap: () =>
                  controller.selectSingleChoice(question.id, choice.id),
            ),
        ],
      );
    });
  }
}

class _MultipleChoiceInput extends GetView<EngagementController> {
  const _MultipleChoiceInput({required this.question});

  final Questions question;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          for (final choice in question.choices)
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: controller.isChoiceSelected(question, choice.id),
              title: Text(choice.text),
              activeColor: TColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (_) =>
                  controller.toggleMultipleChoice(question.id, choice.id),
            ),
        ],
      );
    });
  }
}

class _FreeTextInput extends GetView<EngagementController> {
  const _FreeTextInput({required this.question});

  final Questions question;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('ft_${question.id}'),
      initialValue: controller.freeTextValue(question.id),
      minLines: 3,
      maxLines: 5,
      onChanged: (value) => controller.setFreeText(question.id, value),
      decoration: InputDecoration(
        hintText: 'Type your answer',
        filled: true,
        fillColor: TColors.softGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TColors.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TColors.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
