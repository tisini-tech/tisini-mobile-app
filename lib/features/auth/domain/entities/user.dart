class User {
  final String id;
  final String email;
  final bool isVerified;
  final String firstName;
  final String lastName;
  final String otherName;
  final String phoneNumber;
  final String accessToken;
  final String refreshToken;
  final List<int> roles;

  User({
    required this.id,
    required this.email,
    required this.isVerified,
    required this.firstName,
    required this.lastName,
    required this.otherName,
    required this.phoneNumber,
    required this.accessToken,
    required this.refreshToken,
    required this.roles,
  });
}
