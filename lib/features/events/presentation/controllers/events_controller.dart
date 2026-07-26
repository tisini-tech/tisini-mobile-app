import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/features/events/domain/usecases/scan_ticket.dart';
import 'package:tisini/features/events/presentation/bindings/ticket_binding.dart';
import 'package:tisini/features/events/presentation/pages/ticket_screen.dart';
import 'package:tisini/features/events/presentation/pages/ticket_scanner_screen.dart';

/// Result of a ticket verification (scan or manual).
typedef VerificationResult = ({bool success, String message});

class EventsController extends GetxController {
  static EventsController get instance => Get.find();

  final ScanTicketUsecase scanTicketUsecase;

  EventsController({required this.scanTicketUsecase});

  final Rx<String?> lastScannedTicketCode = Rx<String?>(null);

  /// Latest verification result: success/failure and server message. Null until a verify is done.
  final Rx<VerificationResult?> verificationResult = Rx<VerificationResult?>(
    null,
  );

  /// Loading while verifying (scan or manual).
  final RxBool isVerifying = false.obs;

  final box = GetStorage();
  final manualTicketCodeController = TextEditingController();

  @override
  void onClose() {
    manualTicketCodeController.dispose();
    super.onClose();
  }

  Future<String?> getToken() async {
    return box.read('token') as String?;
  }

  void openCreateTicket() {
    Get.to(() => const TicketScreen(), binding: TicketBinding());
  }

  /// Shared verification: runs use case and updates [verificationResult] and [isVerifying].
  /// Use this after getting a code from scanner or from manual input.
  Future<void> verifyTicket(String code, String method) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      verificationResult.value = (
        success: false,
        message: 'Enter or scan a ticket code.',
      );
      return;
    }

    final token = await getToken();
    if (token == null || token.isEmpty) {
      verificationResult.value = (success: false, message: 'No token found.');
      return;
    }

    isVerifying.value = true;
    verificationResult.value = null;

    final result = await scanTicketUsecase.call(
      ScanTicketParams(ticketCode: trimmed, token: token, method: method),
    );

    isVerifying.value = false;

    result.fold(
      (failure) {
        verificationResult.value = (success: false, message: failure.message);
      },
      (message) {
        verificationResult.value = (success: true, message: message);
      },
    );
  }

  /// Opens camera scanner; on success verifies the scanned code and updates [verificationResult].
  Future<void> openScanTicket() async {
    final code = await Get.to<String>(() => const TicketScannerScreen());
    if (code != null && code.isNotEmpty) {
      lastScannedTicketCode.value = code;
      await verifyTicket(code, '1');
    }
  }

  /// Ticket code prefix; user only types the part after this.
  static const String ticketCodePrefix = 'TKTP-';

  /// Verifies the ticket code from the manual input field (prefix [ticketCodePrefix] + user input, uppercase).
  Future<void> verifyManualEntry() async {
    final suffix = manualTicketCodeController.text.trim().toUpperCase();
    final fullCode = '$ticketCodePrefix$suffix';
    await verifyTicket(fullCode, '2');
  }

  void clearVerificationResult() {
    verificationResult.value = null;
    manualTicketCodeController.clear();
  }
}
