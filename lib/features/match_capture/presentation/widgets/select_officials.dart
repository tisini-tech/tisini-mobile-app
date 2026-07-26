import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/presentation/controllers/officals_controller.dart';

class SelectOfficials extends GetView<MatchOfficialsController> {
  const SelectOfficials({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Select $role'),
        actions: [
          IconButton(
            onPressed: () => _showAddOfficialModal(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Obx(
              () => TextField(
                onChanged: (v) => controller.searchQuery.value = v,
                decoration: InputDecoration(
                  hintText: 'Search officials',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: TColors.textSecondary,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.searchQuery.value.trim().isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => controller.searchQuery.value = '',
                          icon: const Icon(Icons.close_rounded),
                        ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: TColors.borderSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: TColors.primary, width: 1.4),
                  ),
                  filled: true,
                  fillColor: TColors.lightContainer,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(
                () => Text(
                  '${controller.filteredOfficials.length} officials',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: TColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final list = controller.filteredOfficials;
              final selected = controller.selectedOfficial.value;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    controller.searchQuery.value.trim().isEmpty
                        ? 'No officials. Tap + to add.'
                        : 'No officials match your search.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: TColors.textSecondary,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final name = list[index];
                  final isSelected = selected == name;
                  return _OfficialListTile(
                    name: name,
                    isSelected: isSelected,
                    onTap: () {
                      controller.selectedOfficial.value = isSelected ? null : name;
                    },
                  );
                },
              );
            }),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                final selected = controller.selectedOfficial.value;
                final enabled = selected != null && selected.isNotEmpty;
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: enabled
                        ? () {
                            controller.assignOfficialToRole(role, selected);
                            Get.back();
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: TColors.buttonPrimary,
                      foregroundColor: TColors.textWhite,
                      disabledBackgroundColor: TColors.buttonDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      enabled
                          ? 'Assign "$selected" to $role'
                          : 'Select an official to assign',
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOfficialModal(BuildContext context) {
    final nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Add official'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Official name',
            hintText: 'Enter name',
          ),
          onSubmitted: (v) {
            controller.addOfficial(v);
            Get.back();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.addOfficial(nameController.text);
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).whenComplete(() {
      // Defer disposal so the TextField's focus/editing teardown can run first.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nameController.dispose();
      });
    });
  }
}

class _OfficialListTile extends StatelessWidget {
  const _OfficialListTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? TColors.primary.withValues(alpha: 0.12)
            : TColors.lightContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? TColors.primary : TColors.borderSecondary,
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: isSelected
                    ? TColors.primary.withValues(alpha: 0.2)
                    : TColors.darkContainer,
                child: Text(
                  name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isSelected ? TColors.primary : TColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? TColors.primary : TColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
