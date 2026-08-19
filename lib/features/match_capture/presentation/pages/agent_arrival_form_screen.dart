import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/presentation/controllers/agent_arrival_controller.dart';
import 'package:tisini/features/match_capture/presentation/controllers/sop_controller.dart';

class AgentArrivalFormScreen extends GetView<AgentArrivalController> {
  const AgentArrivalFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      appBar: AppBar(
        title: const Text('Record arrival'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const Text(
                  'Take a photo of the pitch. Your GPS location is recorded automatically.',
                  style: TextStyle(
                    color: TColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final path = controller.imagePath.value;
                  final attached = sopHasImage(path);
                  final busy = controller.isPickingImage.value;
                  return Material(
                    color: attached
                        ? TColors.primary.withValues(alpha: 0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: busy ? null : () => controller.pickImage(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: TColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: busy
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.photo_camera_outlined,
                                          color: TColors.primary,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pitch photo',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: TColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        busy
                                            ? 'Opening camera or gallery…'
                                            : attached
                                            ? 'Photo attached'
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
                                    onPressed: busy
                                        ? null
                                        : controller.clearImage,
                                    tooltip: 'Remove',
                                    icon: const Icon(Icons.delete_outline),
                                    color: TColors.error,
                                  )
                                else
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
                                  child: sopImageWidget(path),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Obx(() {
                  final loc = controller.location.value;
                  final fetching = controller.isFetchingLocation.value;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TColors.borderSecondary),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          loc == null
                              ? Icons.location_searching
                              : Icons.location_on_outlined,
                          color: TColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GPS location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: TColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                fetching
                                    ? 'Reading location…'
                                    : loc == null
                                    ? 'Will be captured automatically'
                                    : '${loc.lat.toStringAsFixed(5)}, ${loc.lon.toStringAsFixed(5)}  ·  ±${loc.accuracyM.toStringAsFixed(0)} m',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: TColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Obx(() {
                final submitting = controller.isSubmitting.value;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: submitting ? null : controller.submitArrival,
                    style: FilledButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit arrival',
                            style: TextStyle(fontWeight: FontWeight.w800),
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
}
