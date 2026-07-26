import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture_detail.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture.dart';
import 'package:flutter/material.dart';

class DetailsTab extends StatelessWidget {
  final List<Highlight> details;
  final Fixture fixture;

  const DetailsTab({super.key, required this.details, required this.fixture});

  Icon getEventIcon(Highlight highlight) {
    if (highlight.eventName == "Substitute") {
      return const Icon(
        Icons.swap_horizontal_circle_outlined,
        color: Colors.white,
      );
    } else if (highlight.eventId == 19) {
      // Goal
      return const Icon(Icons.sports_soccer, color: Colors.green);
    } else if (highlight.subeventId == "66") {
      // Try
      return const Icon(Icons.sports_rugby, color: Colors.green);
    } else if (highlight.subeventId == "42") {
      // Missed Conversion
      return const Icon(Icons.cancel_outlined, color: Colors.red);
    } else if (highlight.subeventId == "60") {
      // Successful Conversion
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (highlight.subeventId == "44") {
      // Successful Penalty
      return const Icon(Icons.sports_score, color: Colors.green);
    } else if (highlight.subeventId == "61") {
      // Missed Penalty
      return const Icon(Icons.sports_score, color: Colors.green);
    } else {
      return Icon(
        Icons.stop_rounded,
        color: ["45", "22"].contains(highlight.subeventId)
            ? Colors.red
            : Colors.yellow,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstHalf = details
        .where(
          (detail) =>
              detail.gameMoment == "firsthalf" &&
              detail.eventName != 'Goal Conceded',
        )
        .toList();

    final secondHalf = details
        .where(
          (detail) =>
              detail.gameMoment == "secondhalf" &&
              detail.eventName != 'Goal Conceded',
        )
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _highlightsContainer(context, firstHalf, fixture, 'First half'),
            const SizedBox(height: 10),
            _highlightsContainer(context, secondHalf, fixture, 'Second half'),
            const SizedBox(height: 10),
            fixture.fixtureType != 'football'
                ? _legendContainer(context)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _highlightsContainer(
    BuildContext context,
    List<Highlight> highlights,
    Fixture fixture,
    String title,
  ) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: TColors.darkContainer,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 5),
          const Divider(thickness: 2),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              final highlight = highlights[index];

              if (highlight.team == fixture.team1Id) {
                return _homeTile(highlight);
              } else {
                return _awayTile(highlight);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _homeTile(Highlight highlight) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${highlight.gameMinute}\''),
          const SizedBox(width: 10),
          getEventIcon(highlight),
        ],
      ),
      title: highlight.eventName == "Substitute"
          ? Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${highlight.pname}\n',
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextSpan(
                    text: highlight.jerseyNo,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            )
          : Text(highlight.pname),
    );
  }

  Widget _awayTile(Highlight highlight) {
    return ListTile(
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${highlight.gameMinute}\''),
          const SizedBox(width: 10),
          getEventIcon(highlight),
        ],
      ),
      title: highlight.eventName == "Substitute"
          ? Text.rich(
              textAlign: TextAlign.end,
              TextSpan(
                children: [
                  TextSpan(
                    text: '${highlight.pname}\n',
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextSpan(
                    text: highlight.jerseyNo,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            )
          : Text(highlight.pname, textAlign: TextAlign.end),
    );
  }

  Widget _legendContainer(context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: TColors.darkContainer,
      ),
      child: const Column(
        children: [
          Text('Key'),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.sports_rugby, color: Colors.green),
              SizedBox(width: 5),
              Text('Try'),
            ],
          ),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 5),
              Text("Successful Conversion"),
            ],
          ),
          Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red),
              SizedBox(width: 5),
              Text("Missed Conversion"),
            ],
          ),
          Row(
            children: [
              Icon(Icons.sports_score, color: Colors.green),
              SizedBox(width: 5),
              Text("Successful Penalty"),
            ],
          ),
          Row(
            children: [
              Icon(Icons.sports_score, color: Colors.red),
              SizedBox(width: 5),
              Text("Missed Penalty"),
            ],
          ),
        ],
      ),
    );
  }
}
