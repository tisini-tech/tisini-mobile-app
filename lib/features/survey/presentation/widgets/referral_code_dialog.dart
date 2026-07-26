import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';

/// Returns the entered referral code (trimmed) when user taps Save, or null when skipped.
class ReferralCodeDialog extends StatefulWidget {
  const ReferralCodeDialog({
    super.key,
    required this.initialValue,
  });

  final String initialValue;

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
      title: const Text('Referral Code'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter your referral code',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: TColors.lightContainer,
        ),
        textCapitalization: TextCapitalization.characters,
        autofocus: true,
        onSubmitted: (_) => _save(),
      ),
      actions: [
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
    Get.back(result: _controller.text.trim());
  }
}
