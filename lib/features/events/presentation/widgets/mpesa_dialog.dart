import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';

/// M-Pesa manual payment instructions; [ticketCode] is the account number from the API.
class MpesaDialog extends StatelessWidget {
  const MpesaDialog({super.key, required this.ticketCode});

  final String ticketCode;

  static const String _businessNumber = '4113757';
  static const String _amount = 'KES 0';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TColors.info.withOpacity(0.5), width: 1),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pay manually with M-Pesa',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'If you did not receive an M-Pesa prompt, follow these steps:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 20),
                _step(context, 1, 'Go to your M-Pesa Menu'),
                _step(context, 2, 'Select Lipa na M-Pesa'),
                _step(context, 3, 'Select Pay Bill'),
                _step(context, 4, 'Enter Business Number: $_businessNumber'),
                _step(context, 5, 'Enter Account Number: $ticketCode', boldSuffix: true),
                _step(context, 6, 'Enter Amount: $_amount'),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _step(BuildContext context, int number, String text, {bool boldSuffix = false}) {
    final parts = boldSuffix && text.endsWith(ticketCode)
        ? text.split(ticketCode)
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $number: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TColors.textPrimary,
                ),
          ),
          Expanded(
            child: parts != null
                ? RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TColors.textPrimary,
                          ),
                      children: [
                        TextSpan(text: parts[0]),
                        TextSpan(
                          text: ticketCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (parts.length > 1) TextSpan(text: parts[1]),
                      ],
                    ),
                  )
                : Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TColors.textPrimary,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}
