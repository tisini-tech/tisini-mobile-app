class PlatformVersionPolicy {
  const PlatformVersionPolicy({
    required this.minVersion,
    required this.latestVersion,
    required this.force,
    required this.storeUrl,
  });

  final String minVersion;
  final String latestVersion;
  final bool force;
  final String storeUrl;
}

class AppVersionConfig {
  const AppVersionConfig({
    required this.android,
    required this.ios,
    required this.message,
  });

  final PlatformVersionPolicy android;
  final PlatformVersionPolicy ios;
  final String message;
}

enum AppUpdateDecision { none, optional, required }

class AppUpdateCheck {
  const AppUpdateCheck({
    required this.decision,
    required this.currentVersion,
    required this.policy,
    required this.message,
  });

  final AppUpdateDecision decision;
  final String currentVersion;
  final PlatformVersionPolicy policy;
  final String message;
}

int compareVersions(String a, String b) {
  final left = _parts(a);
  final right = _parts(b);
  final len = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < len; i++) {
    final l = i < left.length ? left[i] : 0;
    final r = i < right.length ? right[i] : 0;
    if (l != r) return l.compareTo(r);
  }
  return 0;
}

List<int> _parts(String version) {
  return [
    for (final part in version.split('.')) int.tryParse(part.trim()) ?? 0,
  ];
}
