import 'package:tisini/core/constants/colors.dart';
import 'package:flutter/material.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.primary,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: TColors.textWhite, size: 24),
    actionsIconTheme: IconThemeData(color: TColors.textWhite, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.textWhite,
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: TColors.white, size: 24),
    actionsIconTheme: IconThemeData(color: TColors.white, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.textWhite,
    ),
  );
}
