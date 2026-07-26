import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/survey.dart';
import 'package:tisini/features/survey/presentation/controllers/engagement_controller.dart';

class SurveyQuestionText extends StatelessWidget {
  const SurveyQuestionText({
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
    final isMultiline = question.multiline == true;

    return Obx(() {
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
          const SizedBox(height: 8),
          _SurveyTextInput(
            key: ValueKey('${question.id}_${ctrl.surveyFormVersion}'),
            questionId: question.id,
            initialValue: ctrl.getAnswerString(question.id) ?? '',
            hint: question.placeholder ?? '',
            multiline: isMultiline,
            errorText: error,
            onChanged: (v) => ctrl.setAnswer(question.id, v),
          ),
        ],
      );
    });
  }
}

class _SurveyTextInput extends StatefulWidget {
  const _SurveyTextInput({
    super.key,
    required this.questionId,
    required this.initialValue,
    required this.hint,
    required this.multiline,
    this.errorText,
    required this.onChanged,
  });

  final int questionId;
  final String initialValue;
  final String hint;
  final bool multiline;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  State<_SurveyTextInput> createState() => _SurveyTextInputState();
}

class _SurveyTextInputState extends State<_SurveyTextInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_SurveyTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: widget.multiline ? 4 : 1,
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: TColors.lightContainer,
      ),
      onChanged: widget.onChanged,
    );
  }
}
