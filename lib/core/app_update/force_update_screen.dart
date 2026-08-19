import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/app_update/app_update_service.dart';
import 'package:tisini/core/app_update/app_version.dart';
import 'package:tisini/core/constants/colors.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppUpdateCheck? check;
    if (Get.arguments is AppUpdateCheck) {
      check = Get.arguments as AppUpdateCheck;
    } else if (Get.isRegistered<AppUpdateService>()) {
      check = Get.find<AppUpdateService>().lastCheck;
    }

    final message = check?.message ??
        'Please update to continue capturing matches.';
    final storeUrl = (check?.policy.storeUrl ?? '').trim().isNotEmpty
        ? check!.policy.storeUrl
        : (Platform.isIOS
            ? 'https://apps.apple.com/app/id6756498066'
            : 'https://play.google.com/store/apps/details?id=com.tisini.app');

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: TColors.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  'assets/tisini-logo.png',
                  width: MediaQuery.sizeOf(context).width * 0.45,
                ),
                const SizedBox(height: 36),
                const Icon(
                  Icons.system_update_alt,
                  size: 48,
                  color: TColors.textWhite,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Update required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: TColors.textWhite,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: TColors.textWhite.withValues(alpha: 0.9),
                  ),
                ),
                if (check != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'This version: ${check.currentVersion}\nRequired: ${check.policy.minVersion}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: TColors.textWhite.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: storeUrl.isEmpty
                        ? null
                        : () {
                            if (!Get.isRegistered<AppUpdateService>()) {
                              Get.put(AppUpdateService(), permanent: true);
                            }
                            Get.find<AppUpdateService>().openStore(storeUrl);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: TColors.secondary,
                      disabledBackgroundColor: TColors.textWhite.withValues(
                        alpha: 0.35,
                      ),
                      foregroundColor: TColors.accent,
                      disabledForegroundColor: TColors.accent.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update now',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
