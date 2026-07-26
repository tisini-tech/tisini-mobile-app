import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/entities/match_event.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';
import 'package:tisini/features/match_capture/presentation/theme/capture_theme.dart';

const _substitutionMetricIds = {17, 39, 52, 110, 226, 252};

const _momentOptions = <({String value, String label})>[
  (value: 'firsthalf', label: '1st Half'),
  (value: 'secondhalf', label: '2nd Half'),
  (value: 'extratime', label: 'Extra Time'),
  (value: 'penalties', label: 'Penalties'),
];

/// Design-first edit sheet for an audited match event.
/// Submit is wired as a callback stub until the update API is ready.
Future<void> showEditMatchEventSheet({
  required BuildContext context,
  required MatchEvent event,
  required List<Metric> metrics,
  required List<Lineup> homeLineup,
  required List<Lineup> awayLineup,
  Future<void> Function(EditMatchEventDraft draft)? onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return EditMatchEventSheet(
        event: event,
        metrics: metrics,
        homeLineup: homeLineup,
        awayLineup: awayLineup,
        onSubmit: onSubmit,
      );
    },
  );
}

class EditMatchEventDraft {
  const EditMatchEventDraft({
    required this.eventId,
    required this.metric,
    required this.metricDetail,
    required this.metricSubDetail,
    required this.player,
    required this.subplayer,
    required this.moment,
    required this.minute,
  });

  final int eventId;
  final Metric metric;
  final Detail? metricDetail;
  final SubDetail? metricSubDetail;
  final Lineup? player;
  final Lineup? subplayer;
  final String moment;
  final int minute;
}

class EditMatchEventSheet extends StatefulWidget {
  const EditMatchEventSheet({
    super.key,
    required this.event,
    required this.metrics,
    required this.homeLineup,
    required this.awayLineup,
    this.onSubmit,
  });

  final MatchEvent event;
  final List<Metric> metrics;
  final List<Lineup> homeLineup;
  final List<Lineup> awayLineup;
  final Future<void> Function(EditMatchEventDraft draft)? onSubmit;

  @override
  State<EditMatchEventSheet> createState() => _EditMatchEventSheetState();
}

class _EditMatchEventSheetState extends State<EditMatchEventSheet> {
  Metric? _metric;
  Detail? _detail;
  SubDetail? _subDetail;
  Lineup? _player;
  Lineup? _subplayer;
  late String _moment;
  late final TextEditingController _minuteController;
  bool _submitting = false;

  List<Lineup> get _teamPlayers {
    final teamId = widget.event.team;
    final homeTeamId = widget.homeLineup.isNotEmpty
        ? widget.homeLineup.first.team
        : null;
    if (homeTeamId != null && teamId == homeTeamId) {
      return widget.homeLineup;
    }
    if (widget.awayLineup.isNotEmpty &&
        teamId == widget.awayLineup.first.team) {
      return widget.awayLineup;
    }

    final playerId = widget.event.player?.id;
    if (playerId != null) {
      if (widget.homeLineup.any((p) => p.player.id == playerId)) {
        return widget.homeLineup;
      }
      if (widget.awayLineup.any((p) => p.player.id == playerId)) {
        return widget.awayLineup;
      }
    }
    return [...widget.homeLineup, ...widget.awayLineup];
  }

  bool get _isSubstitution {
    final metricId = _metric?.id ?? widget.event.metric.id;
    return _substitutionMetricIds.contains(metricId) ||
        widget.event.subplayer != null;
  }

  @override
  void initState() {
    super.initState();
    _metric = _metricById(widget.event.metric.id);
    _detail = _detailById(_metric, widget.event.metricDetail?.id);
    _subDetail = _subDetailById(_metric, widget.event.metricSubDetail?.id);
    _player = _playerById(widget.event.player?.id);
    _subplayer = _playerById(widget.event.subplayer?.id);
    _moment = _normalizeMoment(widget.event.moment);
    _minuteController = TextEditingController(
      text: widget.event.minute.toString(),
    );
  }

  @override
  void dispose() {
    _minuteController.dispose();
    super.dispose();
  }

  Metric? _metricById(int id) {
    for (final metric in widget.metrics) {
      if (metric.id == id) return metric;
    }
    return null;
  }

  Detail? _detailById(Metric? metric, int? detailId) {
    if (metric == null || detailId == null) return null;
    for (final detail in metric.details) {
      if (detail.id == detailId.toString()) return detail;
    }
    return null;
  }

  SubDetail? _subDetailById(Metric? metric, int? subDetailId) {
    if (metric == null || subDetailId == null) return null;
    for (final subDetail in metric.subDetails) {
      if (subDetail.id == subDetailId.toString()) return subDetail;
    }
    return null;
  }

  Lineup? _playerById(int? playerId) {
    if (playerId == null) return null;
    for (final p in [...widget.homeLineup, ...widget.awayLineup]) {
      if (p.player.id == playerId) return p;
    }
    return null;
  }

  String _normalizeMoment(String moment) {
    final normalized = moment.trim().toLowerCase();
    for (final option in _momentOptions) {
      if (option.value == normalized) return option.value;
    }
    return normalized.isEmpty ? _momentOptions.first.value : normalized;
  }

  Future<void> _handleSubmit() async {
    final metric = _metric;
    if (metric == null) return;

    final minute = int.tryParse(_minuteController.text.trim());
    if (minute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid minute')),
      );
      return;
    }

    final draft = EditMatchEventDraft(
      eventId: widget.event.id,
      metric: metric,
      metricDetail: _detail,
      metricSubDetail: _subDetail,
      player: _player,
      subplayer: _isSubstitution ? _subplayer : null,
      moment: _moment,
      minute: minute,
    );

    setState(() => _submitting = true);
    try {
      await widget.onSubmit?.call(draft);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final details = _metric?.details ?? const <Detail>[];
    final subDetails = _metric?.subDetails ?? const <SubDetail>[];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: CaptureTheme.sheetBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFB0BEC5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit event',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: CaptureTheme.surfaceText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.event.metric.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF607D8B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  children: [
                    const _SectionLabel('Event'),
                    const SizedBox(height: 8),
                    _MetricDropdown(
                      label: 'Metric',
                      value: _metric,
                      items: widget.metrics,
                      onChanged: (metric) {
                        setState(() {
                          _metric = metric;
                          _detail = null;
                          _subDetail = null;
                          if (!_substitutionMetricIds.contains(metric?.id)) {
                            _subplayer = null;
                          }
                        });
                      },
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _DetailDropdown(
                        label: 'Metric detail',
                        value: _detail,
                        items: details,
                        onChanged: (detail) => setState(() => _detail = detail),
                      ),
                    ],
                    if (subDetails.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _SubDetailDropdown(
                        label: 'Metric sub detail',
                        value: _subDetail,
                        items: subDetails,
                        onChanged: (sub) => setState(() => _subDetail = sub),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const _SectionLabel('Players'),
                    const SizedBox(height: 8),
                    _PlayerDropdown(
                      label: _isSubstitution ? 'Player out' : 'Player',
                      value: _player,
                      items: _teamPlayers,
                      onChanged: (player) => setState(() => _player = player),
                    ),
                    if (_isSubstitution) ...[
                      const SizedBox(height: 10),
                      _PlayerDropdown(
                        label: 'Player in (sub)',
                        value: _subplayer,
                        items: _teamPlayers,
                        onChanged: (player) =>
                            setState(() => _subplayer = player),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const _SectionLabel('Timing'),
                    const SizedBox(height: 8),
                    Text(
                      'Moment',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF546E7A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in _momentOptions)
                          ChoiceChip(
                            label: Text(option.label),
                            selected: _moment == option.value,
                            onSelected: (_) =>
                                setState(() => _moment = option.value),
                            selectedColor: CaptureTheme.possessionBg,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _moment == option.value
                                  ? CaptureTheme.onDarkFill
                                  : CaptureTheme.surfaceText,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _minuteController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Minute',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _submitting || _metric == null
                        ? null
                        : _handleSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: CaptureTheme.possessionBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Color(0xFF546E7A),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  );
}

class _MetricDropdown extends StatelessWidget {
  const _MetricDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final Metric? value;
  final List<Metric> items;
  final ValueChanged<Metric?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _fieldDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Metric>(
          isExpanded: true,
          value: value,
          hint: const Text('Select metric'),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item.name)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DetailDropdown extends StatelessWidget {
  const _DetailDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final Detail? value;
  final List<Detail> items;
  final ValueChanged<Detail?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _fieldDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Detail>(
          isExpanded: true,
          value: value,
          hint: const Text('Select detail'),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item.name)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SubDetailDropdown extends StatelessWidget {
  const _SubDetailDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final SubDetail? value;
  final List<SubDetail> items;
  final ValueChanged<SubDetail?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _fieldDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SubDetail>(
          isExpanded: true,
          value: value,
          hint: const Text('Select sub detail'),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item.name)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PlayerDropdown extends StatelessWidget {
  const _PlayerDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final Lineup? value;
  final List<Lineup> items;
  final ValueChanged<Lineup?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _fieldDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Lineup>(
          isExpanded: true,
          value: value,
          hint: Text('Select ${label.toLowerCase()}'),
          items: [
            for (final item in items)
              DropdownMenuItem(
                value: item,
                child: Text(
                  '#${item.jerseyNumber} ${item.player.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
