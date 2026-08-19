import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/domain/entities/sop.dart';
import 'package:tisini/features/match_capture/presentation/controllers/sop_controller.dart';

class SopFormScreen extends GetView<SopController> {
  const SopFormScreen({super.key});

  static final _stampFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      appBar: AppBar(
        title: Obx(
          () => Text(controller.isEditing ? 'Edit SOP' : 'Add SOP'),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SectionCard(
            title: 'SOP notes',
            child: Obx(
              () => _EditableStringList(
                items: controller.sopItems.toList(),
                inputController: controller.sopInput,
                hint: 'Add an SOP item',
                onAdd: controller.addSopItem,
                onRemove: controller.removeSopItem,
                emptyLabel: 'No SOP notes yet',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Weather',
            child: Obx(
              () => DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: controller.weather.value,
                isExpanded: true,
                decoration: _inputDecoration(hint: 'Select weather'),
                items: [
                  for (final value in SopWeather.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(SopWeather.labelOf(value)),
                    ),
                ],
                onChanged: (value) => controller.weather.value = value,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Lineup photos',
            child: Obx(
              () => Column(
                children: [
                  _ImageSlot(
                    title: '${controller.homeTeamName} lineup',
                    imagePath: controller.homeLineupImg.value,
                    capturedAt: controller.homeLineupAt.value,
                    stampFormat: _stampFormat,
                    isBusy: controller.isPickingImage.value,
                    onAttach: () => controller.pickImage(
                      context,
                      SopImageTarget.homeLineup,
                    ),
                    onClear: controller.clearHomeLineup,
                  ),
                  const SizedBox(height: 10),
                  _ImageSlot(
                    title: '${controller.awayTeamName} lineup',
                    imagePath: controller.awayLineupImg.value,
                    capturedAt: controller.awayLineupAt.value,
                    stampFormat: _stampFormat,
                    isBusy: controller.isPickingImage.value,
                    onAttach: () => controller.pickImage(
                      context,
                      SopImageTarget.awayLineup,
                    ),
                    onClear: controller.clearAwayLineup,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Referee data',
            child: Column(
              children: [
                Obx(
                  () => _ImageSlot(
                    title: 'Referee data photo',
                    imagePath: controller.refDataImg.value,
                    capturedAt: controller.refDataAt.value,
                    stampFormat: _stampFormat,
                    isBusy: controller.isPickingImage.value,
                    onAttach: () =>
                        controller.pickImage(context, SopImageTarget.refData),
                    onClear: controller.clearRefData,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.refDataInput,
                  onChanged: controller.setRefDataJson,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    hint: 'Referee notes / JSON payload',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Corrections',
            child: Obx(
              () => _EditableStringList(
                items: controller.corrections.toList(),
                inputController: controller.correctionInput,
                hint: 'Add a correction',
                onAdd: controller.addCorrection,
                onRemove: controller.removeCorrection,
                emptyLabel: 'No corrections yet',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.submitSop,
              style: FilledButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.textWhite,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TColors.textWhite,
                      ),
                    )
                  : Text(
                      controller.isEditing ? 'Update SOP' : 'Save SOP',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: TColors.lightContainer,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EditableStringList extends StatelessWidget {
  const _EditableStringList({
    required this.items,
    required this.inputController,
    required this.hint,
    required this.onAdd,
    required this.onRemove,
    required this.emptyLabel,
  });

  final List<String> items;
  final TextEditingController inputController;
  final String hint;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                emptyLabel,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...List.generate(items.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: TColors.softGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(index),
                    icon: const Icon(Icons.close, size: 18),
                    color: TColors.textSecondary,
                  ),
                ],
              ),
            );
          }),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: inputController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onAdd(),
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.textWhite,
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImageSlot extends StatelessWidget {
  const _ImageSlot({
    required this.title,
    required this.imagePath,
    required this.capturedAt,
    required this.stampFormat,
    required this.onAttach,
    required this.onClear,
    this.isBusy = false,
  });

  final String title;
  final String imagePath;
  final DateTime? capturedAt;
  final DateFormat stampFormat;
  final VoidCallback onAttach;
  final VoidCallback onClear;
  final bool isBusy;

  bool get attached => sopHasImage(imagePath);

  @override
  Widget build(BuildContext context) {
    final stamp = capturedAt == null
        ? 'Tap to attach a photo'
        : 'Captured ${stampFormat.format(capturedAt!.toLocal())}';

    return Material(
      color: attached
          ? TColors.primary.withValues(alpha: 0.06)
          : TColors.softGrey,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isBusy ? null : onAttach,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Thumbnail(
                    attached: attached,
                    imagePath: imagePath,
                    isBusy: isBusy,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: TColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isBusy
                              ? 'Opening camera or gallery…'
                              : attached
                              ? stamp
                              : 'Tap to take or choose a photo',
                          style: const TextStyle(
                            fontSize: 12,
                            color: TColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (attached)
                    IconButton(
                      onPressed: isBusy ? null : onClear,
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline),
                      color: TColors.error,
                    )
                  else if (!isBusy)
                    const Icon(
                      Icons.add_a_photo_outlined,
                      color: TColors.primary,
                    ),
                ],
              ),
              if (attached) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: sopImageWidget(imagePath),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.attached,
    required this.imagePath,
    required this.isBusy,
  });

  final bool attached;
  final String imagePath;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: attached
            ? TColors.primary.withValues(alpha: 0.14)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: isBusy
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : attached
          ? sopImageWidget(imagePath)
          : const Icon(
              Icons.photo_camera_outlined,
              color: TColors.textSecondary,
            ),
    );
  }
}
