class User {
  String username;
  String email;

  User({
    required this.username,
    required this.email,
  });

  static User deserialize(jsonUser) {
    return User(
      username: jsonUser["username"],
      email: jsonUser["email"],
    );
  }

  static User updateData(jsonUser, User user) {
    return User(
      username: jsonUser["username"] ?? user.username,
      email: jsonUser["email"] ?? user.email,
    );
  }
}
