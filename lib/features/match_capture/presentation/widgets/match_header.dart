import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/site_images.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';

class MatchHeader extends StatelessWidget {
  const MatchHeader({super.key, required this.fixture});

  final AgentFixture fixture;

  String _teamLogo(String id, Map<String, String> map) {
    return map[id] ?? 'assets/images/homeLogo.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TColors.primary, TColors.primary.withValues(alpha: 0.85)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home team
          Expanded(
            child: _TeamBlock(
              name: fixture.team1Name,
              logoPath: _teamLogo(
                fixture.team1Id.toString(),
                fixture.fixtureType == "football"
                    ? footballImages
                    : rugbyImages,
              ),
            ),
          ),

          // VS badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: TColors.textWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: TColors.textWhite.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Text(
              'VS',
              style: TextStyle(
                color: TColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Away team
          Expanded(
            child: _TeamBlock(
              name: fixture.team2Name,
              logoPath: _teamLogo(
                fixture.team2Id.toString(),
                fixture.fixtureType == "football"
                    ? footballImages
                    : rugbyImages,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  const _TeamBlock({required this.name, required this.logoPath});

  final String name;
  final String logoPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TColors.lightContainer,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: TColors.textWhite.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: ClipOval(
            child: Image.asset(
              logoPath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.sports_soccer, color: TColors.primary, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            name,
            style: const TextStyle(
              color: TColors.textWhite,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
