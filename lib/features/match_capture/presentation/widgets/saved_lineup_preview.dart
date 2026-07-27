import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';

class SavedLineupPlayerEdit {
  const SavedLineupPlayerEdit({
    required this.firstName,
    required this.lastName,
    required this.surname,
    required this.position,
    required this.jerseyNumber,
  });

  final String firstName;
  final String lastName;
  final String surname;
  final String position;
  final int jerseyNumber;

  String get fullName => [
    firstName,
    lastName,
    surname,
  ].map((p) => p.trim()).where((p) => p.isNotEmpty).join(' ');
}

/// Splits a full display name into first / last / surname.
({String firstName, String lastName, String surname}) splitPlayerName(
  String name,
) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return (firstName: '', lastName: '', surname: '');
  }
  if (parts.length == 1) {
    return (firstName: parts[0], lastName: '', surname: '');
  }
  if (parts.length == 2) {
    return (firstName: parts[0], lastName: parts[1], surname: '');
  }
  return (
    firstName: parts[0],
    lastName: parts[1],
    surname: parts.sublist(2).join(' '),
  );
}

/// View of a saved fixture lineup: starters ([playerType] first11) and subs.
class SavedLineupPreview extends StatelessWidget {
  const SavedLineupPreview({
    super.key,
    required this.lineup,
    this.onUpdatePlayer,
  });

  final List<Lineup> lineup;
  final Future<void> Function(Lineup player, SavedLineupPlayerEdit edit)?
  onUpdatePlayer;

  static List<Lineup> startersFrom(List<Lineup> players) {
    final starters = players.where((p) => p.role == 'first11').toList()
      ..sort((a, b) {
        final posA = int.tryParse(a.lineupPosition.toString()) ?? 999;
        final posB = int.tryParse(b.lineupPosition.toString()) ?? 999;
        return posA.compareTo(posB);
      });
    return starters;
  }

  static List<Lineup> subsFrom(List<Lineup> players) {
    return players.where((p) => p.role == 'sub' || p.role == 'subs').toList();
  }

  @override
  Widget build(BuildContext context) {
    final starters = startersFrom(lineup);
    final subs = subsFrom(lineup);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _LineupSection(
          title: 'Starters',
          count: starters.length,
          emptyMessage: 'No starters in lineup',
          players: starters,
          showPosition: true,
          onUpdatePlayer: onUpdatePlayer,
        ),
        const SizedBox(height: 20),
        _LineupSection(
          title: 'Substitutes',
          count: subs.length,
          emptyMessage: 'No substitutes',
          players: subs,
          showPosition: false,
          onUpdatePlayer: onUpdatePlayer,
        ),
      ],
    );
  }
}

class _LineupSection extends StatelessWidget {
  const _LineupSection({
    required this.title,
    required this.count,
    required this.emptyMessage,
    required this.players,
    required this.showPosition,
    this.onUpdatePlayer,
  });

  final String title;
  final int count;
  final String emptyMessage;
  final List<Lineup> players;
  final bool showPosition;
  final Future<void> Function(Lineup player, SavedLineupPlayerEdit edit)?
  onUpdatePlayer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$title ($count)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (players.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: TColors.lightContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TColors.borderSecondary),
            ),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: TColors.textSecondary),
            ),
          )
        else
          ...players.map(
            (player) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SavedLineupPlayerTile(
                player: player,
                showPosition: showPosition,
                onEdit: onUpdatePlayer == null
                    ? null
                    : () => _showEditPlayerDialog(
                        context,
                        player: player,
                        onSave: (edit) => onUpdatePlayer!(player, edit),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> _showEditPlayerDialog(
  BuildContext context, {
  required Lineup player,
  required Future<void> Function(SavedLineupPlayerEdit edit) onSave,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (dialogContext) =>
        _EditPlayerDialog(player: player, onSave: onSave),
  );
}

class _EditPlayerDialog extends StatefulWidget {
  const _EditPlayerDialog({required this.player, required this.onSave});

  final Lineup player;
  final Future<void> Function(SavedLineupPlayerEdit edit) onSave;

  @override
  State<_EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<_EditPlayerDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _positionController;
  late final TextEditingController _jerseyController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final parts = splitPlayerName(widget.player.player.name);
    _firstNameController = TextEditingController(text: parts.firstName);
    _lastNameController = TextEditingController(text: parts.lastName);
    _surnameController = TextEditingController(text: parts.surname);
    _positionController = TextEditingController(
      text: widget.player.player.currentPosition,
    );
    _jerseyController = TextEditingController(
      text: widget.player.jerseyNumber > 0
          ? widget.player.jerseyNumber.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _surnameController.dispose();
    _positionController.dispose();
    _jerseyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    final jersey = int.tryParse(_jerseyController.text.trim());
    if (jersey == null) return;

    final edit = SavedLineupPlayerEdit(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      surname: _surnameController.text.trim(),
      position: _positionController.text.trim(),
      jerseyNumber: jersey,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(edit);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, {String? hint, Widget? prefix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: prefix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: TColors.light,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: TColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: TColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Edit player',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: TColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration('First name'),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration('Last name'),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _surnameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration(
                            'Surname (optional)',
                            hint: 'Surname',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _positionController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration(
                            'Position',
                            hint: 'e.g. Striker',
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter position';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _jerseyController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: _decoration(
                            'Jersey number',
                            hint: 'e.g. 10',
                            prefix: const Icon(Icons.tag),
                          ),
                          validator: (value) {
                            final raw = value?.trim() ?? '';
                            if (raw.isEmpty) return 'Enter a jersey number';
                            final n = int.tryParse(raw);
                            if (n == null) return 'Enter a valid number';
                            if (n < 0 || n > 999) {
                              return 'Use a number between 0 and 999';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: TColors.primary,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

class _SavedLineupPlayerTile extends StatelessWidget {
  const _SavedLineupPlayerTile({
    required this.player,
    required this.showPosition,
    this.onEdit,
  });

  final Lineup player;
  final bool showPosition;
  final VoidCallback? onEdit;

  String? _formattedRating() {
    final value = player.rating?.toString().trim();
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    return number?.toStringAsFixed(1) ?? value;
  }

  @override
  Widget build(BuildContext context) {
    final jersey = player.jerseyNumber.toString().isNotEmpty
        ? player.jerseyNumber.toString()
        : '?';
    final rating = _formattedRating();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: TColors.borderSecondary),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (showPosition &&
                player.lineupPosition.toString().isNotEmpty) ...[
              SizedBox(
                width: 28,
                child: Text(
                  player.lineupPosition.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: TColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            CircleAvatar(
              radius: 20,
              backgroundColor: TColors.primaryBackground,
              child: Text(
                jersey,
                style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.player.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TColors.textPrimary,
                    ),
                  ),
                  if (player.player.currentPosition.trim().isNotEmpty)
                    Text(
                      player.player.currentPosition,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (rating != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: TColors.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: TColors.warning,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit player',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: TColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
