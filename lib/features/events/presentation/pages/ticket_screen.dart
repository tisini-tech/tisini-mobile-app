import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/events/presentation/controllers/ticket_controller.dart';

class TicketScreen extends GetView<TicketController> {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets')),
      backgroundColor: TColors.softGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: TColors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 22,
                        color: TColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: TColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: controller.firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: controller.lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: controller.validateEmail,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            value: controller.countryCode.value,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Code',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 14,
                              ),
                            ),
                            items: TicketController.countryCodes
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e['code'],
                                    child: Text(
                                      e['label']!,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: controller.setCountryCode,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            hintText: 'Phone number',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          validator: controller.validateRequired,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Obx(
                    () => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: controller.verifyChecked.value,
                            onChanged: (v) =>
                                controller.verifyChecked.value = v ?? false,
                            activeColor: TColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: GestureDetector(
                              onTap: controller.toggleVerify,
                              child: Text(
                                'I verify that the details above are correct',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: TColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFE53935)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.submit,
                          borderRadius: BorderRadius.circular(8),
                          child: const Center(
                            child: Text(
                              'Complete Purchase',
                              style: TextStyle(
                                color: TColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
