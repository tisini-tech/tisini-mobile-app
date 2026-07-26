import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackbar(
  String? title,
  String? message,
  Color? backgroundColor, {
  SnackPosition position = SnackPosition.BOTTOM,
  int duration = 2,
}) {
  Get.snackbar(
    title ?? '',
    message ?? '',
    snackPosition: position,
    duration: Duration(seconds: duration),
    colorText: Colors.white,
    backgroundColor: backgroundColor,
    padding: const EdgeInsets.all(12.0),
    borderRadius: 8.0,
  );
}
