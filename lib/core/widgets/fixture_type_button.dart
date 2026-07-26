import 'dart:ffi';

import 'package:flutter/material.dart';

class FixtureTypeButton extends StatelessWidget {
  final String buttonText;
  final Bool isSelected;
  final Icon icon;

  const FixtureTypeButton({
    super.key,
    required this.buttonText,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.03,
        vertical: MediaQuery.sizeOf(context).height * 0.01,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: Colors.black26,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: MediaQuery.sizeOf(context).width * 0.05,
            width: MediaQuery.sizeOf(context).width * 0.05,
            margin: const EdgeInsets.only(right: 10),
            child: const Icon(
              Icons.sports_soccer,
            ),
          ),
          const Text(
            'Football',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
