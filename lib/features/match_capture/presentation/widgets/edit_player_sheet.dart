import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/presentation/widgets/player_position_dropdown.dart';

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

Future<void> showEditPlayerSheet(
  BuildContext context, {
  required Lineup player,
  required Future<void> Function(SavedLineupPlayerEdit edit) onSave,
  String? fixtureType,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (dialogContext) => EditPlayerSheet(
      player: player,
      onSave: onSave,
      fixtureType: fixtureType,
    ),
  );
}

class EditPlayerSheet extends StatefulWidget {
  const EditPlayerSheet({
    super.key,
    required this.player,
    required this.onSave,
    this.fixtureType,
  });

  final Lineup player;
  final Future<void> Function(SavedLineupPlayerEdit edit) onSave;
  final String? fixtureType;

  @override
  State<EditPlayerSheet> createState() => _EditPlayerSheetState();
}

class _EditPlayerSheetState extends State<EditPlayerSheet> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _jerseyController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _position;

  @override
  void initState() {
    super.initState();
    final parts = splitPlayerName(widget.player.player.name);
    _firstNameController = TextEditingController(text: parts.firstName);
    _lastNameController = TextEditingController(text: parts.lastName);
    _surnameController = TextEditingController(text: parts.surname);
    _position = widget.player.player.currentPosition;
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
      position: _position?.trim() ?? '',
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
                        PlayerPositionDropdown(
                          fixtureType: widget.fixtureType,
                          value: _position,
                          decoration: _decoration(
                            'Position',
                            hint: 'Select position',
                          ),
                          onChanged: (value) => setState(() => _position = value),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Select a position';
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
