class User {
  final String sub;
  final String name;
  final String givenName;
  final String familyName;
  final String picture;
  final String email;
  final bool emailVerified;

  const User({
    required this.sub,
    required this.name,
    required this.givenName,
    required this.familyName,
    required this.picture,
    required this.email,
    required this.emailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sub: json['sub'] as String? ?? '',
      name: json['name'] as String? ?? '',
      givenName: json['given_name'] as String? ?? '',
      familyName: json['family_name'] as String? ?? '',
      picture: json['picture'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerified: json['email_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'name': name,
      'given_name': givenName,
      'family_name': familyName,
      'picture': picture,
      'email': email,
      'email_verified': emailVerified,
    };
  }

  User copyWith({
    String? sub,
    String? name,
    String? givenName,
    String? familyName,
    String? picture,
    String? email,
    bool? emailVerified,
  }) {
    return User(
      sub: sub ?? this.sub,
      name: name ?? this.name,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      picture: picture ?? this.picture,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.sub == sub &&
        other.name == name &&
        other.givenName == givenName &&
        other.familyName == familyName &&
        other.picture == picture &&
        other.email == email &&
        other.emailVerified == emailVerified;
  }

  @override
  int get hashCode {
    return Object.hash(
      sub,
      name,
      givenName,
      familyName,
      picture,
      email,
      emailVerified,
    );
  }

  @override
  String toString() {
    return 'User(sub: $sub, name: $name, givenName: $givenName, familyName: $familyName, picture: $picture, email: $email, emailVerified: $emailVerified)';
  }
}
