import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/appbar/custom_appbar.dart';
import 'package:tisini/features/fixtures/presentation/controllers/league_fixture_controller.dart';

class LeaguesScreen extends GetView<LeagueFixtureController> {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.light,
      appBar: const CustomAppBar(),
      body: Obx(() {
        final items = controller.leagues;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Browse leagues',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: TColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a competition to view fixtures and results',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: TColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ...items.map(
              (league) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LeagueTile(
                  name: league['name']!,
                  logoAsset: controller.logoFor(league['id']!),
                  onTap: () {},
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LeagueTile extends StatelessWidget {
  const _LeagueTile({
    required this.name,
    required this.logoAsset,
    required this.onTap,
  });

  final String name;
  final String logoAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TColors.lightContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.borderPrimary),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: TColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  logoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.sports_soccer_rounded,
                    color: TColors.primary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: TColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
