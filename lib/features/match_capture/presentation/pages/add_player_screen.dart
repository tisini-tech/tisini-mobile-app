import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/input_field.dart';
import 'package:tisini/features/match_capture/presentation/controllers/lineup_controller.dart';
import 'package:tisini/features/match_capture/presentation/widgets/player_position_dropdown.dart';

class AddPlayerScreen extends GetView<LineupController> {
  const AddPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamName = controller.team['name'] ?? 'Team';

    return Scaffold(
      appBar: AppBar(
        title: Text('Add player · $teamName'),
      ),
      body: Form(
        key: controller.addPlayerFormKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionTitle(context, 'Personal details'),
                  const SizedBox(height: 12),
                  InputField(
                    label: 'First name',
                    hintText: 'First name',
                    controller: controller.firstNameController,
                    validator: controller.validateRequired,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    label: 'Last name',
                    hintText: 'Last name',
                    controller: controller.lastNameController,
                    validator: controller.validateRequired,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    label: 'Surname (optional)',
                    hintText: 'Surname',
                    controller: controller.sirNameController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  DateInputField(
                    label: 'Date of birth',
                    hintText: 'YYYY-MM-DD',
                    controller: controller.dobController,
                    validator: controller.validateRequired,
                    onTap: () => controller.pickDate(
                      context,
                      target: controller.dobController,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Player details'),
                  const SizedBox(height: 12),
                  Obx(
                    () => PlayerPositionDropdown(
                      fixtureType: controller.fixture.value?.fixtureType,
                      value: controller.selectedPosition.value,
                      onChanged: (value) =>
                          controller.selectedPosition.value = value,
                      validator: controller.validateRequired,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    label: 'Jersey number',
                    hintText: 'Jersey',
                    controller: controller.jerseyController,
                    validator: controller.validateRequired,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  DateInputField(
                    label: 'Contract end date',
                    hintText: 'YYYY-MM-DD',
                    controller: controller.contractController,
                    validator: controller.validateRequired,
                    onTap: () => controller.pickDate(
                      context,
                      target: controller.contractController,
                      initial: DateTime.now(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Contact (optional fields)'),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: controller.countryCode.value,
                            isExpanded: true,
                            decoration: appInputDecoration('Country code'),
                            items: LineupController.countryCodes
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
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: InputField(
                          label: 'Phone (optional)',
                          hintText: '712345678',
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    label: 'ID number (optional)',
                    hintText: 'National ID',
                    controller: controller.idnoController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    label: 'Email (optional)',
                    hintText: 'player@example.com',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateOptionalEmail,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.isAddingPlayer.value
                        ? null
                        : controller.submitAddPlayer,
                    child: controller.isAddingPlayer.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save player'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: TColors.textPrimary,
          ),
    );
  }
}
