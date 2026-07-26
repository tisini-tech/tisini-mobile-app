import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/site_images.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';

/// Match header: teams, score/kick-off, optional toolbar — used on options & stats screens.
class FixtureMatchHeader extends StatelessWidget {
  const FixtureMatchHeader({
    super.key,
    required this.fixture,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final AgentFixture fixture;
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  static bool isNotStarted(String status) {
    final n = status.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    return n == 'notstarted';
  }

  static String momentLabel(AgentFixture f) {
    if (isNotStarted(f.gameStatus)) return f.matchtime;
    if (f.gameStatus.toLowerCase() == 'started') return "${f.minute}'";
    if (f.gameStatus.toUpperCase() == 'HT') return 'Half time';
    if (f.gameStatus.toUpperCase() == 'FT') return 'Full time';
    return f.gameStatus.toUpperCase();
  }

  static int scoreValue(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  String _teamLogo(int teamId) {
    final map =
        fixture.fixtureType == 'football' ? footballImages : rugbyImages;
    return map[teamId.toString()] ?? 'assets/images/homeLogo.png';
  }

  @override
  Widget build(BuildContext context) {
    final notStarted = isNotStarted(fixture.gameStatus);
    final home = scoreValue(fixture.homeScore);
    final away = scoreValue(fixture.awayScore);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: TColors.textWhite),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: TColors.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                child: trailing ?? const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: _TeamColumn(
                    name: fixture.team1Name,
                    logoPath: _teamLogo(fixture.team1Id),
                  ),
                ),
                Expanded(
                  child: notStarted
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'vs',
                              style: TextStyle(
                                color: TColors.textWhite,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (fixture.matchtime.isNotEmpty)
                              Text(
                                fixture.matchtime,
                                style: const TextStyle(
                                  color: TColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$home : $away',
                              style: const TextStyle(
                                color: TColors.textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              momentLabel(fixture),
                              style: const TextStyle(
                                color: TColors.textWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
                Expanded(
                  child: _TeamColumn(
                    name: fixture.team2Name,
                    logoPath: _teamLogo(fixture.team2Id),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({required this.name, required this.logoPath});

  final String name;
  final String logoPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: TColors.primaryBackground,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(logoPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: TColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
