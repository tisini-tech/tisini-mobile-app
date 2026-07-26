import 'package:tisini/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.primary,
      body: Center(
        child: Image.asset(
          "assets/tisini-logo.png",
          width: MediaQuery.sizeOf(context).width * 0.5,
        ),
      ),
    );
  }

  void navigate() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed("/home");
    });
  }
}
