class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.isVerified,
  });

  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final bool isVerified;

  String get roleLabel {
    return switch (role) {
      '1' => 'Agent',
      '5' => 'Player',
      '7' => 'Super agent',
      _ => role.isEmpty ? 'User' : 'Role $role',
    };
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
