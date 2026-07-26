import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tisini/core/constants/colors.dart';

/// Six-digit OTP-style input with individual boxes and paste support.
class VerificationCodeField extends StatefulWidget {
  const VerificationCodeField({
    super.key,
    this.length = 6,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.autofocus = false,
    this.enabled = true,
  });

  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final bool enabled;

  @override
  State<VerificationCodeField> createState() => _VerificationCodeFieldState();
}

class _VerificationCodeFieldState extends State<VerificationCodeField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _focusNode = FocusNode();
    _controller.addListener(_syncLength);
  }

  void _syncLength() {
    final text = _controller.text;
    if (text.length > widget.length) {
      _controller.text = text.substring(0, widget.length);
      _controller.selection = TextSelection.collapsed(offset: widget.length);
    }
    setState(() {});
  }

  void _handleInput(FormFieldState<String> field, String value) {
    field.didChange(value);
    widget.onChanged?.call(value);

    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_syncLength);
    _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.disabled,
      initialValue: _controller.text,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(widget.length, (index) {
                      final char = index < _controller.text.length
                          ? _controller.text[index]
                          : '';
                      final nextIndex = _controller.text.length;
                      final isActive =
                          _focusNode.hasFocus &&
                          nextIndex < widget.length &&
                          index == nextIndex;

                      return _CodeBox(
                        digit: char,
                        isActive: isActive && widget.enabled,
                        hasError: field.hasError,
                        enabled: widget.enabled,
                      );
                    }),
                  ),
                  Opacity(
                    opacity: 0,
                    child: SizedBox(
                      height: 56,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: widget.autofocus,
                        enabled: widget.enabled,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: widget.length,
                        enableInteractiveSelection: false,
                        autocorrect: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => _handleInput(field, value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (field.hasError) ...[
              const SizedBox(height: 8),
              Text(
                field.errorText!,
                style: const TextStyle(
                  color: TColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
    required this.enabled,
  });

  final String digit;
  final bool isActive;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? TColors.error
        : isActive
        ? TColors.primary
        : TColors.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? TColors.lightContainer : TColors.darkContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isActive || hasError ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: TColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: enabled ? TColors.textPrimary : TColors.textSecondary,
          height: 1,
        ),
      ),
    );
  }
}
