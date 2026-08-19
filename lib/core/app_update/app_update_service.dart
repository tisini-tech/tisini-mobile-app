import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tisini/core/app_update/app_version.dart';
import 'package:tisini/core/app_update/app_version_remote.dart';

class AppUpdateService {
  AppUpdateService({AppVersionRemoteSource? remote})
    : _remote = remote ?? AppVersionRemoteSource();

  final AppVersionRemoteSource _remote;

  AppUpdateCheck? lastCheck;

  /// Network failure fails open so a downed API does not lock the app.
  Future<AppUpdateCheck?> check() async {
    try {
      final config = await _remote.fetch();
      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      final policy = Platform.isIOS ? config.ios : config.android;

      AppUpdateDecision decision = AppUpdateDecision.none;
      if (compareVersions(current, policy.minVersion) < 0) {
        decision = AppUpdateDecision.required;
      } else if (compareVersions(current, policy.latestVersion) < 0) {
        decision = AppUpdateDecision.optional;
      }

      final result = AppUpdateCheck(
        decision: decision,
        currentVersion: current,
        policy: policy,
        message: config.message,
      );
      lastCheck = result;
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<void> openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
