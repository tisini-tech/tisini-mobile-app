import 'package:flutter/material.dart';
import 'package:tisini/features/match_capture/domain/entities/metrics.dart';

/// Outdoor-optimized palette for live match capture (high contrast, matte fills).
abstract final class CaptureTheme {
  CaptureTheme._();

  static const Color onDarkFill = Color(0xFFFFFFFF);

  // Team tile fills — home red / away green (high outdoor contrast)
  static const Color homeTileFill = Color(0xFFB71C1C);
  static const Color homeAccent = Color(0xFF7F0000);
  static const Color homeText = onDarkFill;
  static const Color homeLabel = Color(0xFF7F0000);

  static const Color awayTileFill = Color(0xFF2E7D32);
  static const Color awayAccent = Color(0xFF1B5E20);
  static const Color awayText = onDarkFill;
  static const Color awayLabel = Color(0xFF1B5E20);

  // Pitch & column backdrops — light team-tinted greys
  static const Color pitchTint = Color(0xFFE8EAF6);
  static const Color homeColumnBg = Color(0xFFFFEBEE);
  static const Color awayColumnBg = Color(0xFFE8F5E9);

  static const Color selectedFill = Color(0xFF1565C0);
  static const Color selectedText = onDarkFill;
  static const Color selectedBorder = Color(0xFF0D47A1);

  static const Color sheetBackground = Color(0xFFFAFAFA);
  static const Color subsBenchBg = Color(0xFFB0BEC5);

  // Event category fills — dark saturated hues, white labels
  static const Color scoringBg = Color(0xFF2E7D32);
  static const Color scoringText = onDarkFill;

  static const Color possessionBg = Color(0xFF1565C0);
  static const Color possessionText = onDarkFill;

  static const Color defenseBg = Color(0xFF283593);
  static const Color defenseText = onDarkFill;

  static const Color disciplineBg = Color(0xFFE65100);
  static const Color disciplineText = onDarkFill;

  static const Color setPieceBg = Color(0xFF6A1B9A);
  static const Color setPieceText = onDarkFill;

  static const Color goalkeepingBg = Color(0xFF004D40);
  static const Color goalkeepingText = onDarkFill;

  static const Color generalBg = Color(0xFF455A64);
  static const Color generalText = onDarkFill;

  /// Dark text for labels on light surfaces (sheets, headers).
  static const Color surfaceText = Color(0xFF212121);

  static const double minTouchHeight = 48;
  static const double eventFontSize = 13;
  static const double eventFontSizeCompact = 12;
  static const double subEventFontSize = 15;
  static const double playerJerseyFontSize = 24;
  static const double playerNameFontSize = 13.5;
  static const double subsJerseyFontSize = 18;
  static const double subsBarJerseyHeight = 40;
  static const double subsNameFontSize = 11;

  static const List<Shadow> playerNameShadows = [
    Shadow(color: Color(0xF2FFFFFF), blurRadius: 4),
    Shadow(color: Color(0x66000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static Color teamPanelBg(bool isHomeTeam) =>
      isHomeTeam ? homeColumnBg : awayColumnBg;

  static Color teamTileFill(bool isHomeTeam) =>
      isHomeTeam ? homeTileFill : awayTileFill;

  static Color teamAccent(bool isHomeTeam) =>
      isHomeTeam ? homeAccent : awayAccent;

  static Color teamText(bool isHomeTeam) => isHomeTeam ? homeText : awayText;

  static Color teamLabel(bool isHomeTeam) => isHomeTeam ? homeLabel : awayLabel;

  static CaptureEventCategory categoryFromStatId(String statCategoryId) {
    switch (statCategoryId) {
      case '5': // football attack
      case '8': // rugby attack
        return CaptureEventCategory.scoring;
      case '4': // football possession
      case '12': // rugby possession
      case '13': // territory
      case '14': // territorial kicks
        return CaptureEventCategory.possession;
      case '3': // football defense
      case '9': // rugby defense
        return CaptureEventCategory.defense;
      case '1': // football discipline
      case '10': // rugby discipline
        return CaptureEventCategory.discipline;
      case '11': // set piece
        return CaptureEventCategory.setPiece;
      case '6': // goalkeeping
        return CaptureEventCategory.goalkeeping;
      default:
        return CaptureEventCategory.general;
    }
  }

  static CaptureEventCategory categoryForEvent(Metric event) =>
      categoryFromStatId(event.metricCategory.toString());

  static ({Color background, Color text, Color border}) teamEventColors(
    bool isHomeTeam,
  ) {
    return (
      background: teamTileFill(isHomeTeam),
      text: onDarkFill,
      border: teamAccent(isHomeTeam),
    );
  }

  static ({Color background, Color text, Color border}) eventColors(
    CaptureEventCategory category,
    bool isHomeTeam,
  ) {
    final (bg, text) = switch (category) {
      CaptureEventCategory.scoring => (scoringBg, scoringText),
      CaptureEventCategory.possession => (possessionBg, possessionText),
      CaptureEventCategory.defense => (defenseBg, defenseText),
      CaptureEventCategory.discipline => (disciplineBg, disciplineText),
      CaptureEventCategory.setPiece => (setPieceBg, setPieceText),
      CaptureEventCategory.goalkeeping => (goalkeepingBg, goalkeepingText),
      CaptureEventCategory.general => (generalBg, generalText),
    };
    // Team accent bar distinguishes home vs away on shared category hues.
    return (background: bg, text: text, border: teamAccent(isHomeTeam));
  }

  static ({Color background, Color text, Color border}) eventColorsFor(
    Metric event,
    bool isHomeTeam,
  ) => eventColors(categoryForEvent(event), isHomeTeam);

  static TextStyle eventLabelStyle({
    required Color color,
    required bool compact,
  }) {
    return TextStyle(
      fontSize: compact ? eventFontSizeCompact : eventFontSize,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.15,
      letterSpacing: 0.2,
    );
  }

  static TextStyle subEventLabelStyle(Color color) => TextStyle(
    fontSize: subEventFontSize,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.2,
  );

  static TextStyle playerJerseyStyle({
    required bool isSelected,
    required bool isHomeTeam,
  }) {
    return TextStyle(
      fontSize: playerJerseyFontSize,
      fontWeight: FontWeight.w800,
      color: isSelected ? selectedText : teamText(isHomeTeam),
      height: 1,
    );
  }

  static TextStyle playerNameStyle({
    required bool isSelected,
    required bool isHomeTeam,
  }) {
    return TextStyle(
      fontSize: playerNameFontSize,
      fontWeight: FontWeight.w800,
      color: isSelected ? selectedBorder : teamLabel(isHomeTeam),
      height: 1.1,
      letterSpacing: 0.15,
      shadows: playerNameShadows,
    );
  }

  static TextStyle subsNameStyle({
    required bool isSelected,
    required bool isHomeTeam,
  }) {
    return TextStyle(
      fontSize: subsNameFontSize,
      fontWeight: FontWeight.w700,
      color: isSelected ? selectedBorder : teamLabel(isHomeTeam),
      height: 1.1,
      shadows: playerNameShadows,
    );
  }

  static BoxDecoration playerNameChipDecoration({required bool isHomeTeam}) {
    return BoxDecoration(
      color: onDarkFill.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: teamAccent(isHomeTeam).withValues(alpha: 0.35),
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration playerTileDecoration({
    required bool isHomeTeam,
    required bool isSelected,
    bool isGoalkeeper = false,
  }) {
    if (isSelected) {
      return BoxDecoration(
        color: selectedFill,
        border: Border.all(color: selectedBorder, width: 3),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: isGoalkeeper ? goalkeepingBg : teamTileFill(isHomeTeam),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x4D000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static const double eventAccentWidth = 4;
  static const double eventBorderRadius = 8;
  static const Color eventOutline = Color(0xFF37474F);

  /// Home accent sits on the left; away on the right (mirrors column position).
  static BorderRadius teamAccentBarRadius(
    bool isHomeTeam, {
    double radius = eventBorderRadius,
  }) {
    return isHomeTeam
        ? BorderRadius.horizontal(left: Radius.circular(radius))
        : BorderRadius.horizontal(right: Radius.circular(radius));
  }

  static Widget teamAccentBar({
    required bool isHomeTeam,
    required Color color,
    double width = eventAccentWidth,
    double radius = eventBorderRadius,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: teamAccentBarRadius(isHomeTeam, radius: radius),
      ),
    );
  }

  static List<Widget> mirroredAccentRow({
    required bool isHomeTeam,
    required Color accentColor,
    required Widget content,
    double accentWidth = eventAccentWidth,
    double radius = eventBorderRadius,
  }) {
    final bar = teamAccentBar(
      isHomeTeam: isHomeTeam,
      color: accentColor,
      width: accentWidth,
      radius: radius,
    );
    final expanded = Expanded(child: content);
    return isHomeTeam ? [bar, expanded] : [expanded, bar];
  }

  static BoxDecoration eventButtonDecoration({
    required Color background,
    bool highlighted = false,
  }) {
    final borderColor = highlighted
        ? selectedBorder
        : Color.alphaBlend(
            const Color(0x66000000),
            background,
          );

    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(eventBorderRadius),
      border: Border.all(
        color: borderColor,
        width: highlighted ? 3 : 1.5,
      ),
      boxShadow: highlighted
          ? [
              BoxShadow(
                color: selectedBorder.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
    );
  }
}

enum CaptureEventCategory {
  scoring,
  possession,
  defense,
  discipline,
  setPiece,
  goalkeeping,
  general,
}
