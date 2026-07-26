import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/theme/appbar_theme.dart';
import 'package:tisini/core/theme/bottom_sheet_theme.dart';
import 'package:tisini/core/theme/elevated_button_theme.dart';
import 'package:tisini/core/theme/outlined_buton_theme.dart';
import 'package:tisini/core/theme/text_field_theme.dart';
import 'package:tisini/core/theme/text_theme.dart';
import 'package:flutter/material.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: ,
    brightness: Brightness.light,
    primaryColor: TColors.primary,
    textTheme: TTextTheme.lightTextTheme,
    scaffoldBackgroundColor: TColors.primaryBackground,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    outlinedButtonTheme: TOutlinedButonTheme.lightOutlinedButtonTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightelevatedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: ,
    brightness: Brightness.dark,
    primaryColor: TColors.primary,
    textTheme: TTextTheme.darkTextTheme,
    scaffoldBackgroundColor: TColors.dark,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    outlinedButtonTheme: TOutlinedButonTheme.darkOutlinedButtonTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkelevatedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  );
}

// const lightColorScheme = ColorScheme(
//   brightness: Brightness.light,
//   primary: Color(0xFF1A237E), // Dark Blue
//   onPrimary: Color(0xFFFFFFFF), // White
//   secondary: Color(0xFF536DFE), // Indigo A200
//   onSecondary: Color(0xFFFFFFFF), // White
//   error: Color(0xFFBA1A1A), // Red
//   onError: Color(0xFFFFFFFF), // White
//   // background: Color(0xFFFCFDF6), // Light Background
//   // onBackground: Color(0xFF1A1C18), // Dark text on light background
//   shadow: Color(0xFF000000), // Black
//   outlineVariant: Color(0xFFC2C8BC), // Light Outline
//   surface: Color(0xFFF9FAF3), // Light Surface
//   onSurface: Color(0xFF1A1C18), // Dark text on light surface
// );

// const darkColorScheme = ColorScheme(
//   brightness: Brightness.dark,
//   primary: Color(0xFF1A237E), // Dark Blue
//   onPrimary: Color(0xFFFFFFFF), // White
//   secondary: Color(0xFF536DFE), // Indigo A200
//   onSecondary: Color(0xFFFFFFFF), // White
//   error: Color(0xFFBA1A1A), // Red
//   onError: Color(0xFFFFFFFF), // White
//   // background: Color(0xFF121212), // Dark Background
//   // onBackground: Color(0xFFE0E0E0), // Light text on dark background
//   shadow: Color(0xFF000000), // Black
//   outlineVariant: Color(0xFF37474F), // Dark Outline
//   surface: Color(0xFF1E1E1E), // Dark Surface
//   onSurface: Color(0xFFE0E0E0), // Light text on dark surface
//   tertiary: Color(0xFF4CAF50), // Green for accent
//   onTertiary: Color(0xFFFFFFFF), // White
// );

// final ThemeData lightMode = ThemeData(
//   useMaterial3: true,
//   brightness: Brightness.light,
//   colorScheme: lightColorScheme,
//   // textTheme: TextTheme(
//   //   headline1: TextStyle(color: lightColorScheme.onBackground),
//   //   headline2: TextStyle(color: lightColorScheme.onBackground),
//   //   headline3: TextStyle(color: lightColorScheme.onBackground),
//   //   headline4: TextStyle(color: lightColorScheme.onBackground),
//   //   headline5: TextStyle(color: lightColorScheme.onBackground),
//   //   headline6: TextStyle(color: lightColorScheme.onBackground),
//   //   subtitle1: TextStyle(color: lightColorScheme.onBackground),
//   //   subtitle2: TextStyle(color: lightColorScheme.onBackground),
//   //   bodyText1: TextStyle(color: lightColorScheme.onBackground),
//   //   bodyText2: TextStyle(color: lightColorScheme.onBackground),
//   //   caption: TextStyle(color: lightColorScheme.onBackground),
//   //   button: TextStyle(color: lightColorScheme.onPrimary),
//   //   overline: TextStyle(color: lightColorScheme.onBackground),
//   // ),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ButtonStyle(
//       backgroundColor: WidgetStateProperty.all<Color>(lightColorScheme.primary),
//       foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
//       elevation: WidgetStateProperty.all<double>(5.0),
//       padding: WidgetStateProperty.all<EdgeInsets>(
//           const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
//       shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//         RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     ),
//   ),
// );

// final ThemeData darkMode = ThemeData(
//   useMaterial3: true,
//   brightness: Brightness.dark,
//   colorScheme: darkColorScheme,
//   // textTheme: TextTheme(
//   //   headline1: TextStyle(color: darkColorScheme.onBackground),
//   //   headline2: TextStyle(color: darkColorScheme.onBackground),
//   //   headline3: TextStyle(color: darkColorScheme.onBackground),
//   //   headline4: TextStyle(color: darkColorScheme.onBackground),
//   //   headline5: TextStyle(color: darkColorScheme.onBackground),
//   //   headline6: TextStyle(color: darkColorScheme.onBackground),
//   //   subtitle1: TextStyle(color: darkColorScheme.onBackground),
//   //   subtitle2: TextStyle(color: darkColorScheme.onBackground),
//   //   bodyText1: TextStyle(color: darkColorScheme.onBackground),
//   //   bodyText2: TextStyle(color: darkColorScheme.onBackground),
//   //   caption: TextStyle(color: darkColorScheme.onBackground),
//   //   button: TextStyle(color: darkColorScheme.onPrimary),
//   //   overline: TextStyle(color: darkColorScheme.onBackground),
//   // ),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ButtonStyle(
//       backgroundColor: WidgetStateProperty.all<Color>(darkColorScheme.primary),
//       foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
//       elevation: WidgetStateProperty.all<double>(5.0),
//       padding: WidgetStateProperty.all<EdgeInsets>(
//           const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
//       shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//         RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     ),
//   ),
// );
