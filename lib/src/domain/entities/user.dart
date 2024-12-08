class User {
  final String id;
  final String username;
  final String email;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePictureUrl,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? profilePictureUrl,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  User.fromJson(Map<String, dynamic> map, String id)
      : id = id,
        username = map['username'],
        email = map['email'],
        profilePictureUrl = map['profilePictureUrl'];
}
