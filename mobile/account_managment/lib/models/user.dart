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
}
