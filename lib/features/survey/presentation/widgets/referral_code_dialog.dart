import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';

/// Returns the entered value (trimmed) when user taps Save, or null when skipped.
class ReferralCodeDialog extends StatefulWidget {
  const ReferralCodeDialog({
    super.key,
    required this.initialValue,
    this.title = 'Referral Code',
    this.hintText = 'Enter your referral code',
    this.showSkip = true,
  });

  final String initialValue;
  final String title;
  final String hintText;
  final bool showSkip;

  @override
  State<ReferralCodeDialog> createState() => _ReferralCodeDialogState();
}

class _ReferralCodeDialogState extends State<ReferralCodeDialog> {
  late final TextEditingController _controller;

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
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: TColors.lightContainer,
        ),
        textCapitalization: TextCapitalization.characters,
        autofocus: true,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        if (widget.showSkip)
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Skip'),
          ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: TColors.primary,
            foregroundColor: TColors.textWhite,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Get.back(result: value);
  }
}
