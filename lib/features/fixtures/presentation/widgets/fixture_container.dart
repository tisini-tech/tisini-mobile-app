import 'package:flutter/material.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/constants/site_images.dart';
import 'package:tisini/features/fixtures/domain/entities/fixture.dart';
import 'package:tisini/features/fixtures/presentation/widgets/fixture_row.dart';

class FixtureContainer extends StatelessWidget {
  const FixtureContainer({
    super.key,
    required this.league,
    required this.fixtures,
  });

  final String league;
  final List<Fixture> fixtures;

  String getLeagueLogo(String id) {
    final logos = leagues;
    return logos[id] ?? 'assets/images/awayLogo.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.02),
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset(getLeagueLogo(league)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      league,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // league fixtures
          Column(
            children: fixtures.map((fixture) {
              return FixtureRow(fixture: fixture);
            }).toList(),
          ),
        ],
      ),
    );
  }
}
