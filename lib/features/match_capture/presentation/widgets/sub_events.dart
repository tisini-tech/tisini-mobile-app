import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/capture_tap_shell.dart';

/// Bottom sheet for nested metric [Detail] choices.
class SubEvents extends StatelessWidget {
  const SubEvents({
    super.key,
    required this.controller,
    required this.isHomeTeam,
    this.onAfterSubmit,
  });

  final MatchCaptureController controller;
  final bool isHomeTeam;
  final VoidCallback? onAfterSubmit;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _MetricOptionSheet(
        title: 'Select Sub-Event',
        isHomeTeam: isHomeTeam,
        options: [
          for (final detail in controller.filteredSubEvents)
            (id: detail.id, name: detail.name),
        ],
        onSelect: (id) {
          final detail = controller.filteredSubEvents.firstWhereOrNull(
            (d) => d.id == id,
          );
          if (detail == null) return;

          controller.selectSubEvent(detail);
          Navigator.pop(context);

          if (controller.needsSubDetailPicker) {
            Future.microtask(() {
              Get.bottomSheet(
                MetricSubDetails(
                  controller: controller,
                  isHomeTeam: isHomeTeam,
                  onAfterSubmit: onAfterSubmit,
                ),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            });
          } else {
            controller.submitMetric(isHomeTeam: isHomeTeam);
            onAfterSubmit?.call();
          }
        },
      );
    });
  }
}

/// Bottom sheet for nested metric [SubDetail] choices.
class MetricSubDetails extends StatelessWidget {
  const MetricSubDetails({
    super.key,
    required this.controller,
    required this.isHomeTeam,
    this.onAfterSubmit,
  });

  final MatchCaptureController controller;
  final bool isHomeTeam;
  final VoidCallback? onAfterSubmit;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subDetails = controller.selectedEvent.value?.subDetails ?? const <SubDetail>[];

      return _MetricOptionSheet(
        title: 'Select Sub-Detail',
        isHomeTeam: isHomeTeam,
        options: [
          for (final subDetail in subDetails)
            (id: subDetail.id, name: subDetail.name),
        ],
        onSelect: (id) {
          final subDetail = subDetails.firstWhereOrNull((d) => d.id == id);
          if (subDetail == null) return;

          Navigator.pop(context);
          controller.selectSubDetail(subDetail);
          controller.submitMetric(isHomeTeam: isHomeTeam);
          onAfterSubmit?.call();
        },
      );
    });
  }
}

class _MetricOptionSheet extends StatelessWidget {
  const _MetricOptionSheet({
    required this.title,
    required this.isHomeTeam,
    required this.options,
    required this.onSelect,
  });

  final String title;
  final bool isHomeTeam;
  final List<({String id, String name})> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = CaptureTheme.teamEventColors(isHomeTeam);
    final rowCount = (options.length / 3.0).ceil();
    final dialogHeight = (rowCount * 72.0) + 140.0;

    return Container(
      height: dialogHeight.clamp(
        320.0,
        MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: CaptureTheme.sheetBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: CaptureTheme.surfaceText,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];

                return CaptureTapShell(
                  key: ValueKey('metric_option_${option.id}_$isHomeTeam'),
                  onTap: () => onSelect(option.id),
                  builder: (context, flashing) {
                    final background = flashing
                        ? CaptureTheme.selectedFill
                        : colors.background;
                    final textColor = flashing
                        ? CaptureTheme.selectedText
                        : colors.text;
                    final accentColor = flashing
                        ? CaptureTheme.selectedBorder
                        : colors.border;

                    return Material(
                      color: Colors.transparent,
                      child: Ink(
                        decoration: CaptureTheme.eventButtonDecoration(
                          background: background,
                          highlighted: flashing,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: CaptureTheme.mirroredAccentRow(
                            isHomeTeam: isHomeTeam,
                            accentColor: accentColor,
                            radius: 12,
                            content: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                child: Text(
                                  option.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: CaptureTheme.subEventLabelStyle(
                                    textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
