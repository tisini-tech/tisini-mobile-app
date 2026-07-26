import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/events/presentation/controllers/events_controller.dart';

class EventsScreen extends GetView<EventsController> {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Column(
        children: [
          // Top 1/4: verification result
          Expanded(
            flex: 1,
            child: Obx(() {
              final result = controller.verificationResult.value;
              return _VerificationResultView(
                controller: controller,
                result: result,
              );
            }),
          ),
          // Bottom 3/4: actions and manual entry
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.openCreateTicket,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create ticket'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final isVerifying = controller.isVerifying.value;
                    return ElevatedButton.icon(
                      onPressed: isVerifying ? null : controller.openScanTicket,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan ticket'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        minimumSize: const Size(double.infinity, 48),
                        disabledBackgroundColor: TColors.primary.withOpacity(
                          0.8,
                        ),
                        disabledForegroundColor: TColors.textWhite,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Or enter ticket code (after ${EventsController.ticketCodePrefix})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.manualTicketCodeController,
                    decoration: InputDecoration(
                      hintText: 'e.g. ABC123',
                      border: const OutlineInputBorder(),
                      prefixText: EventsController.ticketCodePrefix,
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => controller.verifyManualEntry(),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final isVerifying = controller.isVerifying.value;
                    return ElevatedButton.icon(
                      onPressed: isVerifying
                          ? null
                          : controller.verifyManualEntry,
                      icon: isVerifying
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: TColors.textWhite,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        isVerifying ? 'Verifying...' : 'Verify ticket',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        minimumSize: const Size(double.infinity, 52),
                        disabledBackgroundColor: TColors.primary.withOpacity(
                          0.8,
                        ),
                        disabledForegroundColor: TColors.textWhite,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Converts input to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _VerificationResultView extends StatelessWidget {
  const _VerificationResultView({
    required this.controller,
    required this.result,
  });

  final EventsController controller;
  final VerificationResult? result;

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const SizedBox.shrink();
    }
    final r = result!;
    final isSuccess = r.success;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        color: isSuccess
            ? TColors.success.withOpacity(0.15)
            : TColors.error.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                color: isSuccess ? TColors.success : TColors.error,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSuccess ? 'Ticket verified' : 'Verification failed',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSuccess ? TColors.success : TColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(r.message),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.clearVerificationResult,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
