import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/survey.dart';
import 'package:tisini/features/survey/presentation/controllers/engagement_controller.dart';

class SurveyQuestionContact extends StatelessWidget {
  const SurveyQuestionContact({
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
    final fields = question.fields ?? [];

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
          if (error != null) ...[
            const SizedBox(height: 4),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TColors.error,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          ...fields.map((f) {
            final name = f['name'] ?? '';
            final label = f['label'] ?? name;
            final placeholder = f['placeholder'] ?? '';
            final key = '${question.id}_$name';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ContactField(
                key: ValueKey('${key}_${ctrl.surveyFormVersion}'),
                storageKey: key,
                initialValue: ctrl.getAnswerString(key) ?? '',
                label: label,
                placeholder: placeholder,
                keyboardType: f['type'] == 'tel'
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                onChanged: (v) => ctrl.setAnswer(key, v),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _ContactField extends StatefulWidget {
  const _ContactField({
    super.key,
    required this.storageKey,
    required this.initialValue,
    required this.label,
    required this.placeholder,
    required this.keyboardType,
    required this.onChanged,
  });

  final String storageKey;
  final String initialValue;
  final String label;
  final String placeholder;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  @override
  State<_ContactField> createState() => _ContactFieldState();
}

class _ContactFieldState extends State<_ContactField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: TColors.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: TColors.lightContainer,
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
