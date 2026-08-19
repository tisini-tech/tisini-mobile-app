import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/presentation/controllers/match_capture_controller.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';
import 'package:tisini/features/match_capture/presentation/widgets/match_recording_guard.dart';

class BehaviourScreen extends GetView<MatchCaptureController> {
  const BehaviourScreen({super.key, this.bypassGuard = false});

  /// When true, the match-start guard is skipped on submit (retrospective entry).
  final bool bypassGuard;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final metrics = controller.behaviourMetrics;
      final player = controller.playerForStatSheet;

      return SafeArea(
        child: Scaffold(
          backgroundColor: CaptureTheme.sheetBackground,
          appBar: AppBar(
            title: Text(
              player != null
                  ? '${player.player.name} — Behaviour'
                  : 'Behaviour Traits',
            ),
            centerTitle: true,
          ),
          body: metrics.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No behaviour metrics available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                  ),
                )
              : _BehaviourForm(
                  metrics: metrics,
                  isHomeTeam: controller.isHomeTeam,
                  bypassGuard: bypassGuard,
                ),
        ),
      );
    });
  }
}

/// Stateful form — one radio group per behaviour metric.
class _BehaviourForm extends StatefulWidget {
  const _BehaviourForm({
    required this.metrics,
    required this.isHomeTeam,
    this.bypassGuard = false,
  });

  final List<Metric> metrics;
  final bool isHomeTeam;
  final bool bypassGuard;

  @override
  State<_BehaviourForm> createState() => _BehaviourFormState();
}

class _BehaviourFormState extends State<_BehaviourForm> {
  /// metricId -> selected Detail (null = nothing chosen yet)
  late final Map<int, Detail?> _selections;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selections = {for (final m in widget.metrics) m.id: null};
  }

  void _select(int metricId, Detail detail) {
    setState(() => _selections[metricId] = detail);
  }

  Future<void> _submit() async {
    final hasAny = _selections.values.any((d) => d != null);
    if (!hasAny) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one behaviour rating.'),
        ),
      );
      return;
    }

    if (!widget.bypassGuard &&
        !await ensureMatchRecordingAllowed(context: context)) return;

    setState(() => _submitting = true);
    final controller = Get.find<MatchCaptureController>();
    await controller.submitBehaviourForm(
      isHomeTeam: widget.isHomeTeam,
      selections: Map.unmodifiable(_selections),
      bypassGuard: widget.bypassGuard,
    );
    if (mounted) {
      setState(() => _submitting = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: widget.metrics.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final metric = widget.metrics[i];
              return _MetricCard(
                metric: metric,
                selected: _selections[metric.id],
                onSelect: (detail) => _select(metric.id, detail),
              );
            },
          ),
        ),
        _SubmitBar(submitting: _submitting, onSubmit: _submit),
      ],
    );
  }
}

/// Card for a single metric — shows metric name and its detail options as radio chips.
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.selected,
    required this.onSelect,
  });

  final Metric metric;
  final Detail? selected;
  final ValueChanged<Detail> onSelect;

  @override
  Widget build(BuildContext context) {
    final details = metric.details;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Metric name header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: CaptureTheme.disciplineBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Text(
              metric.name,
              style: const TextStyle(
                color: CaptureTheme.disciplineText,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),

          // Detail options
          if (details.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No rating options available.',
                style: TextStyle(color: Colors.black45, fontSize: 13),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final detail in details)
                    _DetailRow(
                      detail: detail,
                      isSelected: selected?.id == detail.id,
                      onTap: () => onSelect(detail),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.detail,
    required this.isSelected,
    required this.onTap,
  });

  final Detail detail;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Row(
          children: [
            Radio<String>(
              value: detail.id,
              groupValue: isSelected ? detail.id : null,
              onChanged: (_) => onTap(),
              activeColor: CaptureTheme.disciplineBg,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                detail.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? CaptureTheme.disciplineBg
                      : CaptureTheme.surfaceText,
                ),
              ),
            ),
            if (detail.strength != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CaptureTheme.disciplineBg
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  detail.strength!.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.submitting, required this.onSubmit});

  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: ElevatedButton.icon(
          onPressed: submitting ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: CaptureTheme.disciplineBg,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          icon: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_outline, size: 22),
          label: Text(
            submitting ? 'Saving…' : 'Submit Behaviour',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
