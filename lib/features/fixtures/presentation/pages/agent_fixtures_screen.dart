import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/container/container_header.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/fixtures/presentation/controllers/agent_fixture_controller.dart';

class AgentFixturesScreen extends GetView<AgentFixtureController> {
  const AgentFixturesScreen({super.key});

  static const double _headerHeight = 220;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      body: RefreshIndicator(
        color: TColors.primary,
        onRefresh: controller.getAgentFixtures,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ContainerHeader(
                height: _headerHeight,
                child: SizedBox(
                  height: _headerHeight,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Fixtures',
                            style: TextStyle(
                              color: TColors.textWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          TextField(
                            controller: controller.searchController,
                            onChanged: controller.setSearchQuery,
                            style: const TextStyle(color: TColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Search teams or venue',
                              hintStyle: TextStyle(
                                color: TColors.textWhite.withValues(alpha: 0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color:
                                    TColors.textWhite.withValues(alpha: 0.85),
                              ),
                              suffixIcon: Obx(
                                () => controller.searchQuery.value.isEmpty
                                    ? const SizedBox.shrink()
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: TColors.textWhite,
                                          size: 20,
                                        ),
                                        onPressed: controller.clearSearch,
                                      ),
                              ),
                              filled: true,
                              fillColor:
                                  TColors.textWhite.withValues(alpha: 0.15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: controller.refreshFixtures,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Refresh'),
                              style: TextButton.styleFrom(
                                foregroundColor: TColors.textWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(child: _fixturesList(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fixturesList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final fixtures = controller.filteredFixtures;

      if (controller.fixtures.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Center(
            child: Text(
              'No fixtures assigned yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: TColors.textSecondary,
                  ),
            ),
          ),
        );
      }

      if (fixtures.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Text(
            'No fixtures match "${controller.searchQuery.value}"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: TColors.textSecondary,
                ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: fixtures.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) =>
            _FixtureTile(fixture: fixtures[index]),
      );
    });
  }
}

class _FixtureTile extends StatelessWidget {
  const _FixtureTile({required this.fixture});

  final AgentFixture fixture;

  static bool _isNotStarted(String status) {
    final n = status.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    return n == 'notstarted';
  }

  static int _score(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static _MatchPhase _phase(AgentFixture f) {
    if (_isNotStarted(f.gameStatus)) {
      return _MatchPhase.upcoming;
    }
    final s = f.gameStatus.toLowerCase();
    if (s == 'started') return _MatchPhase.live;
    if (f.gameStatus.toUpperCase() == 'HT') return _MatchPhase.halfTime;
    if (f.gameStatus.toUpperCase() == 'FT') return _MatchPhase.fullTime;
    return _MatchPhase.live;
  }

  static String _phaseLabel(_MatchPhase phase, AgentFixture f) {
    return switch (phase) {
      _MatchPhase.upcoming => 'Upcoming',
      _MatchPhase.live => "Live · ${f.minute}'",
      _MatchPhase.halfTime => 'Half time',
      _MatchPhase.fullTime => 'Full time',
    };
  }

  static Color _accentColor(_MatchPhase phase) {
    return switch (phase) {
      _MatchPhase.upcoming => TColors.grey,
      _MatchPhase.live => TColors.success,
      _MatchPhase.halfTime => TColors.warning,
      _MatchPhase.fullTime => TColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = AgentFixtureController.instance;
    final phase = _phase(fixture);
    final notStarted = phase == _MatchPhase.upcoming;
    final home = _score(fixture.homeScore);
    final away = _score(fixture.awayScore);
    final accent = _accentColor(phase);
    final pitch = fixture.pitchname?.toString().trim() ?? '';
    final subtitle = _subtitle(fixture, pitch);

    return Material(
      color: TColors.lightContainer,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => controller.goToFixtureOptionsScreen(fixture),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            _phaseLabel(phase, fixture),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                          if (fixture.matchday.isNotEmpty) ...[
                            Text(
                              ' · ${fixture.matchday}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: TColors.textSecondary,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (fixture.fixtureType.isNotEmpty)
                            Text(
                              fixture.fixtureType,
                              style: const TextStyle(
                                fontSize: 11,
                                color: TColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              fixture.team1Name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: _teamStyle(
                                context,
                                highlight: !notStarted && home > away,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: Center(
                              child: notStarted
                                  ? Text(
                                      fixture.matchtime.isNotEmpty
                                          ? fixture.matchtime
                                          : '—',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: TColors.primary,
                                      ),
                                    )
                                  : Text(
                                      '$home  -  $away',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: TColors.textPrimary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              fixture.team2Name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: _teamStyle(
                                context,
                                highlight: !notStarted && away > home,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: TColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: TColors.borderPrimary,
                size: 20,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  static TextStyle _teamStyle(
    BuildContext context, {
    required bool highlight,
  }) {
    return Theme.of(context).textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: highlight ? TColors.primary : TColors.textPrimary,
        );
  }

  static String? _subtitle(AgentFixture fixture, String pitch) {
    if (pitch.isNotEmpty) return pitch;
    return null;
  }
}

enum _MatchPhase { upcoming, live, halfTime, fullTime }
