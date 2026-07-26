import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tisini/core/constants/colors.dart';

/// Shared outline decoration for form fields across the app.
InputDecoration appInputDecoration(
  String label, {
  String? hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    suffixIcon: suffixIcon,
  );
}

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.label,
    this.errorMsg = '',
    required this.hintText,
    this.password = false,
    this.validator,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final String errorMsg;
  final String hintText;
  final bool password;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      obscureText: widget.password && _obscureText,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      decoration: appInputDecoration(widget.label, hintText: widget.hintText)
          .copyWith(
            suffixIcon: widget.password
                ? IconButton(
                    tooltip: _obscureText ? 'Show password' : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: TColors.textSecondary,
                    ),
                  )
                : null,
          ),
    );
  }
}

/// Read-only field that opens a date picker on tap.
class DateInputField extends StatelessWidget {
  const DateInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onTap,
    this.validator,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      decoration: appInputDecoration(label, hintText: hintText).copyWith(
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
      ),
    );
  }
}
