import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tisini/core/constants/colors.dart';

/// Shared shimmer palette: brand-tinted, clearer than grey but softer than full [TColors.primary].
abstract final class FixtureShimmerStyle {
  FixtureShimmerStyle._();

  static const Color base = Color(0xFFB8C8E8);
  static const Color highlight = Color(0xFF5B9FEB);
  static const Color fill = TColors.primaryBackground;

  static Widget box({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  static Widget circle(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(width: 1, color: TColors.borderPrimary),
      ),
      child: ClipOval(
        child: Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(color: fill),
        ),
      ),
    );
  }
}
