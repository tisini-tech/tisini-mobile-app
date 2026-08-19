import 'package:flutter/material.dart';
import 'package:tisini/core/constants/player_positions.dart';
import 'package:tisini/core/widgets/input_field.dart';

class PlayerPositionDropdown extends StatelessWidget {
  const PlayerPositionDropdown({
    super.key,
    required this.fixtureType,
    required this.value,
    required this.onChanged,
    this.validator,
    this.decoration,
  });

  final String? fixtureType;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final options = PlayerPositions.forFixtureType(fixtureType);
    final selected = PlayerPositions.match(value, fixtureType);

    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: selected,
      isExpanded: true,
      decoration:
          decoration ?? appInputDecoration('Position', hintText: 'Select position'),
      items: [
        for (final position in options)
          DropdownMenuItem(value: position, child: Text(position)),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
