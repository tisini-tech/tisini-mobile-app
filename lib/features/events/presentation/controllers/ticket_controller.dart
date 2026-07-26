import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/events/domain/usecases/create_ticket.dart';
import 'package:tisini/features/events/presentation/widgets/mpesa_dialog.dart';

class TicketController extends GetxController {
  final CreateTicketUsecase createTicketUsecase;

  TicketController({required this.createTicketUsecase});

  final box = GetStorage();

  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final RxString countryCode = '+254'.obs;
  final RxBool verifyChecked = false.obs;

  static const List<Map<String, String>> countryCodes = [
    {'code': '+254', 'label': 'KE +254'},
    {'code': '+255', 'label': 'TZ +255'},
    {'code': '+256', 'label': 'UG +256'},
    {'code': '+250', 'label': 'RW +250'},
    {'code': '+1', 'label': 'US +1'},
    {'code': '+44', 'label': 'UK +44'},
  ];

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void setCountryCode(String? value) {
    countryCode.value = value ?? '+254';
  }

  void toggleVerify() {
    verifyChecked.value = !verifyChecked.value;
  }

  Future<String?> getToken() async {
    return box.read('token') as String?;
  }

  Future<void> submit() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        'Error',
        'No token found',
        backgroundColor: TColors.error,
        colorText: TColors.textWhite,
      );
      return;
    }

    if (!verifyChecked.value) {
      Get.snackbar(
        'Required',
        'Please verify that your details are correct',
        backgroundColor: TColors.error,
        colorText: TColors.textWhite,
      );
      return;
    }
    if (formKey.currentState?.validate() ?? false) {
      // TODO: submit to API
      final result = await createTicketUsecase.call(
        CreateTicketParams(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          phone: phoneController.text,
          quantity: '1',
          eventId: '3',
          ticketId: '4',
          token: token,
        ),
      );

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: TColors.error,
            colorText: TColors.textWhite,
          );
        },
        (success) {
          Get.snackbar(
            'Success',
            success.message,
            backgroundColor: TColors.success,
            colorText: TColors.textWhite,
          );
          if (success.ticketCode.isNotEmpty) {
            Get.dialog(MpesaDialog(ticketCode: success.ticketCode));
          }
        },
      );
    }
  }

  String? validateRequired(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'Enter a valid email';
    }
    return null;
  }
}
