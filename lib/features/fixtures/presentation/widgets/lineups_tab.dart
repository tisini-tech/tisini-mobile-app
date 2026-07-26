import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture.dart';
import 'package:tisini/shared/fixture_data/domain/entities/lineup.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_lineup.dart';
import 'package:tisini/features/fixtures/presentation/widgets/tip_player.dart';

class LineupsTab extends StatelessWidget {
  final FixtureLineups lineups;
  final Fixture fixture;

  const LineupsTab({super.key, required this.lineups, required this.fixture});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: fixture.fixtureType == "football"
          ? Column(
              children: [
                _homePlayers(context),
                _awayPlayers(context),
                _substitutes(context),
              ],
            )
          : Column(children: [_rugbyPlayers(context), _substitutes(context)]),
    );
  }

  Widget _homePlayers(BuildContext context) {
    final hPlayers = lineups.home;

    if (hPlayers.length > 1) {
      return _playersContainer(
        context,
        'assets/images/home-pitch.png',
        Column(
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_lineupTile(context, hPlayers[0])],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _lineupTile(context, hPlayers[1]),
                  _lineupTile(context, hPlayers[2]),
                  _lineupTile(context, hPlayers[3]),
                  _lineupTile(context, hPlayers[4]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _lineupTile(context, hPlayers[6]),
                  _lineupTile(context, hPlayers[7]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _lineupTile(context, hPlayers[5]),
                  _lineupTile(context, hPlayers[9]),
                  _lineupTile(context, hPlayers[8]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_lineupTile(context, hPlayers[10])],
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _awayPlayers(BuildContext context) {
    final aPlayers = lineups.away;

    if (aPlayers.length > 1) {
      return _playersContainer(
        context,
        'assets/images/away-pitch.png',
        Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_lineupTile(context, aPlayers[10], away: true)],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _lineupTile(context, aPlayers[8], away: true),
                  _lineupTile(context, aPlayers[9], away: true),
                  _lineupTile(context, aPlayers[5], away: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _lineupTile(context, aPlayers[7], away: true),
                  _lineupTile(context, aPlayers[6], away: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _lineupTile(context, aPlayers[4], away: true),
                  _lineupTile(context, aPlayers[3], away: true),
                  _lineupTile(context, aPlayers[2], away: true),
                  _lineupTile(context, aPlayers[1], away: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_lineupTile(context, aPlayers[0], away: true)],
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _playersContainer(BuildContext context, String img, Widget child) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
      ),
      child: child,
    );
  }

  Widget _rugbyPlayers(BuildContext context) {
    final aPlayers = lineups.away;
    final hPlayers = lineups.home;

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColors.darkContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text('Lineup', style: TextStyle(fontWeight: FontWeight.w600)),
          const Divider(),
          Row(
            children: [
              _subsTile(context, true, hPlayers),
              _subsTile(context, false, aPlayers),
            ],
          ),
        ],
      ),
    );
  }

  Widget _substitutes(BuildContext context) {
    final aSubs = lineups.away
        .where((player) => player.playerType == "sub")
        .toList();
    final hSubs = lineups.home
        .where((player) => player.playerType == "sub")
        .toList();

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColors.darkContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text('Subs', style: TextStyle(fontWeight: FontWeight.w600)),
          const Divider(),
          Row(
            children: [
              _subsTile(context, true, hSubs),
              _subsTile(context, false, aSubs),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineupTile(BuildContext context, Lineup player, {bool away = false}) {
    final name = player.pname.split(' ');

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) {
            return TipPlayer(matchPlayer: player);
          },
        );
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/t-shirt.png',
                color: away == true ? Colors.orange : TColors.primary,
                scale: 14,
              ),
              Text(
                player.jerseyNo,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            name.length > 1 && name[1] == ""
                ? '${name[0][0]}. ${name[2]}'
                : '${name[0][0]}. ${name[1]}',
            style: const TextStyle(
              color: TColors.textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subsTile(BuildContext context, bool home, List<Lineup> subs) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subs.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final player = subs[index];

          return ListTile(
            leading: home ? Text(player.jerseyNo) : const SizedBox(),
            title: Text(
              player.pname,
              textAlign: home ? TextAlign.start : TextAlign.end,
            ),
            trailing: home ? const SizedBox.shrink() : Text(player.jerseyNo),
          );
        },
      ),
    );
  }
}
