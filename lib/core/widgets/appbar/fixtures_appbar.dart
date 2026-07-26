import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/presentation/controllers/live_fixture_controller.dart';

/// Slightly taller than default so logo + sport select read clearly.
const double _kAppBarHeight = 64;

class FixturesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FixturesAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _kAppBarHeight,
      centerTitle: false,
      titleSpacing: 16,
      title: Image.asset(
        'assets/tisini-logo.png',
        height: 48,
        fit: BoxFit.contain,
      ),
      actions: [
        if (Get.isRegistered<LiveFixtureController>())
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: _FixtureTypeSelect(
                controller: Get.find<LiveFixtureController>(),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_kAppBarHeight);
}

class _FixtureTypeSelect extends StatelessWidget {
  const _FixtureTypeSelect({required this.controller});

  final LiveFixtureController controller;

  static const _closedTextStyle = TextStyle(
    color: TColors.primary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const _menuTextStyle = TextStyle(
    color: TColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  String _label(String type) {
    if (type.isEmpty) return type;
    return '${type[0].toUpperCase()}${type.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final types = controller.fixtureTypesList;
      if (types.isEmpty) return const SizedBox.shrink();

      final selected = types.contains(controller.fixtureType.value)
          ? controller.fixtureType.value
          : types.first;

      return SizedBox(
        width: 148,
        height: 42,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: TColors.lightContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: TColors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected,
                isDense: true,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: TColors.primary,
                  size: 26,
                ),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: TColors.lightContainer,
                elevation: 6,
                menuMaxHeight: 240,
                selectedItemBuilder: (context) => types
                    .map(
                      (type) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_label(type), style: _closedTextStyle),
                      ),
                    )
                    .toList(),
                items: types.map((type) {
                  final isSelected = type == selected;
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TColors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _label(type),
                        style: _menuTextStyle.copyWith(
                          color: isSelected
                              ? TColors.primary
                              : TColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.selectFixtureType(value);
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}
