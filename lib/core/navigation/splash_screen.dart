import 'package:tisini/core/app_update/app_update_service.dart';
import 'package:tisini/core/app_update/app_version.dart';
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
    _start();
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

  Future<void> _start() async {
    final started = DateTime.now();
    if (!Get.isRegistered<AppUpdateService>()) {
      Get.put(AppUpdateService(), permanent: true);
    }

    final check = await Get.find<AppUpdateService>().check();
    final elapsed = DateTime.now().difference(started);
    final remaining = const Duration(seconds: 2) - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    if (check?.decision == AppUpdateDecision.required) {
      Get.offAllNamed('/force-update', arguments: check);
      return;
    }

    Get.offAllNamed('/home');
  }
}
