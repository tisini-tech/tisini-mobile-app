/// Payload for registering a new player on a team.
class NewPlayerInput {
  final String firstName;
  final String lastName;
  final String? sirName;
  final String dob;
  final String position;
  final String? phone;
  final String? idno;
  final String countrycode;
  final String jersey;
  final String contract;
  final String? email;

  const NewPlayerInput({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.position,
    required this.countrycode,
    required this.jersey,
    required this.contract,
    this.sirName,
    this.phone,
    this.idno,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'position': position,
      'countrycode': countrycode,
      'jersey': jersey,
      'contract': contract,
    };
    final sirNameValue = sirName?.trim();
    if (sirNameValue != null && sirNameValue.isNotEmpty) {
      map['sirName'] = sirNameValue;
    }
    final phoneValue = phone?.trim();
    if (phoneValue != null && phoneValue.isNotEmpty) {
      map['phone'] = phoneValue;
    }
    final idnoValue = idno?.trim();
    if (idnoValue != null && idnoValue.isNotEmpty) {
      map['idno'] = idnoValue;
    }
    final emailValue = email?.trim();
    if (emailValue != null && emailValue.isNotEmpty) {
      map['email'] = emailValue;
    }
    return map;
  }
}
