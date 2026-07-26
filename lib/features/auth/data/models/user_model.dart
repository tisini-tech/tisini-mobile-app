import 'package:tisini/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.isVerified,
    required super.firstName,
    required super.lastName,
    required super.otherName,
    required super.phoneNumber,
    required super.accessToken,
    required super.refreshToken,
    required super.roles,
  });

  UserModel copyWith({
    String? id,
    String? email,
    bool? isVerified,
    String? firstName,
    String? lastName,
    String? otherName,
    String? phoneNumber,
    String? accessToken,
    String? refreshToken,
    List<int>? roles,
  }) => UserModel(
    id: id ?? this.id,
    email: email ?? this.email,
    isVerified: isVerified ?? this.isVerified,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    otherName: otherName ?? this.otherName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    roles: roles ?? this.roles,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    isVerified: _parseBool(json['is_verified']),
    firstName: json['first_name']?.toString() ?? '',
    lastName: json['last_name']?.toString() ?? '',
    otherName: json['other_name']?.toString() ?? '',
    phoneNumber: json['phone_number']?.toString() ?? '',
    accessToken: json['access_token']?.toString() ?? '',
    refreshToken: json['refresh_token']?.toString() ?? '',
    roles: _parseRoles(json['roles']),
  );

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    final s = value.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  static List<int> _parseRoles(dynamic value) {
    if (value is! List) return [];
    final roles = <int>[];
    for (final role in value) {
      if (role is int) {
        roles.add(role);
      } else {
        final parsed = int.tryParse(role.toString());
        if (parsed != null) roles.add(parsed);
      }
    }
    return roles;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "is_verified": isVerified,
    "first_name": firstName,
    "last_name": lastName,
    "other_name": otherName,
    "phone_number": phoneNumber,
    "access_token": accessToken,
    "refresh_token": refreshToken,
    "roles": roles,
  };
}
