import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/presentation/controllers/officals_controller.dart';
import 'package:tisini/features/match_capture/presentation/widgets/match_header.dart';
import 'package:tisini/features/match_capture/presentation/widgets/select_officials.dart';

class MatchOfficialsScreen extends GetView<MatchOfficialsController> {
  const MatchOfficialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fixture = controller.fixture.value;
    if (fixture == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Officials')),
        body: const Center(child: Text('No fixture selected.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Match Officials')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MatchHeader(fixture: fixture),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Obx(
                    () => Column(
                      children: MatchOfficialsController.officialRoles
                          .map(
                            (role) => _OfficialTile(
                              role: role,
                              name: controller.nameForRole(role),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficialTile extends StatelessWidget {
  const _OfficialTile({required this.role, required this.name});

  final String role;
  final String name;

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? 'none' : name;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TColors.borderSecondary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: name.isEmpty
                        ? TColors.textSecondary
                        : TColors.textPrimary,
                    fontStyle: name.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Get.to(() => SelectOfficials(role: role));
            },
            icon: Icon(Icons.edit_outlined, color: TColors.primary, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}
