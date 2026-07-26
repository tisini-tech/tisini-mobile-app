import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/survey.dart';
import 'package:tisini/features/survey/presentation/controllers/engagement_controller.dart';
import 'package:tisini/features/survey/presentation/widgets/survey_question_choice.dart';
import 'package:tisini/features/survey/presentation/widgets/survey_question_contact.dart';
import 'package:tisini/features/survey/presentation/widgets/survey_question_text.dart';

class EngagementScreen extends GetView<EngagementController> {
  const EngagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const SizedBox(width: 48),
            ],
          ),
        ),
        actions: [
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
              onPressed: syncing
                  ? null
                  : () => controller.syncPendingResponses(),
              tooltip: 'Sync saved responses',
            );
          }),
        ],
      ),
      body: Obx(() {
        final current = controller.currentQuestion;
        final total = controller.totalQuestions;
        final index = controller.currentQuestionIndex.value;
        final isFirst = controller.isFirstQuestion;
        final isLast = controller.isLastQuestion;

        if (controller.surveys.isEmpty) {
          return const Center(child: Text('Loading surveys...'));
        }
        debugPrint('Current survey: ${controller.surveys[0]}');

        if (current == null || total == 0) {
          return const Center(child: Text('No questions in this survey'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${index + 1} of $total',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                child: _buildQuestion(context, current),
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
                          onPressed: () => controller.goToPreviousQuestion(),
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
                      flex: 1,
                      child: FilledButton(
                        onPressed: () => isLast
                            ? controller.submitEngagement()
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

  Widget _buildQuestion(BuildContext context, Question q) {
    switch (q.type) {
      case 'text':
        return SurveyQuestionText(question: q, delegate: controller);
      case 'choice':
        return SurveyQuestionChoice(question: q, delegate: controller);
      case 'contact':
        return SurveyQuestionContact(question: q, delegate: controller);
      default:
        return SurveyQuestionText(question: q, delegate: controller);
    }
  }
}
