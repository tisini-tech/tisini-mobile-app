import 'package:tisini/features/match_capture/domain/entities/formation.dart';

/// Predefined football formations (GK row first, then defence, midfield, attack).
/// columnsPerRow: [GK, row2, row3, ...] = players per row from back to front.
class FormationConstants {
  FormationConstants._();

  static const Formation formation1433 = Formation(
    name: '1-4-3-3',
    columnsPerRow: [1, 4, 3, 3],
    lineupOrder: [1, 2, 4, 5, 3, 6, 8, 10, 7, 9, 11],
  );

  static const Formation formation1442 = Formation(
    name: '1-4-4-2',
    columnsPerRow: [1, 4, 4, 2],
    lineupOrder: [1, 2, 4, 5, 3, 7, 6, 8, 11, 9, 10],
  );

  static const Formation formation14231 = Formation(
    name: '1-4-2-3-1',
    columnsPerRow: [1, 4, 2, 3, 1],
    lineupOrder: [1, 2, 4, 5, 3, 6, 8, 7, 10, 11, 9],
  );

  static const Formation formation1343 = Formation(
    name: '1-3-4-3',
    columnsPerRow: [1, 3, 4, 3],
    lineupOrder: [1, 2, 3, 4, 5, 6, 8, 7, 9, 10, 11],
  );

  // Rugby 15s formations
  static const Formation formation323223 = Formation(
    name: '3-2-3-2-2-3',
    columnsPerRow: [3, 2, 3, 2, 2, 3],
    lineupOrder: [1, 2, 3, 4, 5, 6, 8, 7, 9, 10, 12, 13, 11, 15, 14],
  );

  static const Formation formation323133 = Formation(
    name: '3-2-3-1-3-3',
    columnsPerRow: [3, 2, 3, 1, 3, 3],
    lineupOrder: [1, 2, 3, 4, 5, 6, 8, 7, 9, 12, 10, 13, 11, 15, 14],
  );

  // Rugby 10s formations
  static const Formation formation3232 = Formation(
    name: '3-2-3-2',
    columnsPerRow: [3, 2, 3, 2],
    lineupOrder: [1, 2, 3, 4, 5, 6, 8, 7, 9, 10],
  );

  // Rugby 7s formations
  static const Formation formation31111 = Formation(
    name: '3-1-1-1-1',
    columnsPerRow: [3, 1, 1, 1, 1],
    lineupOrder: [1, 2, 3, 4, 5, 6, 7],
  );

  // Basketball formations
  static const Formation formation122 = Formation(
    name: '1-2-2',
    columnsPerRow: [1, 2, 2],
    lineupOrder: [1, 2, 3, 4, 5],
  );

  // Handball formations
  static const Formation formation133 = Formation(
    name: '1-3-3',
    columnsPerRow: [1, 3, 3],
    lineupOrder: [1, 2, 3, 4, 5, 6, 8, 7, 9, 10, 11],
  );

  static const List<Formation> footballFormations = [
    formation1433,
    formation1442,
    formation14231,
    formation1343,
  ];

  static const List<Formation> rugby15Formations = [
    formation323223,
    formation323133,
  ];

  static const List<Formation> rugby7Formations = [formation31111];

  static const List<Formation> rugby10Formations = [formation3232];

  static const List<Formation> basketballFormations = [formation122];

  static const List<Formation> hockeyFormations = [formation1433];

  static const List<Formation> handballFormations = [formation133];
}
