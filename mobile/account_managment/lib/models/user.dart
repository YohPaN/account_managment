import 'package:account_managment/models/account.dart';

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

  bool hasPermission({
    dynamic ressource,
    Account? account,
    required List<String> permissionsNeeded,
    required List<dynamic> permissions,
    bool strict = true,
  }) {
    assert(
      !(ressource == null && account == null),
      "You must provide a ressource or an account",
    );
    if ((account != null && account.username == username) ||
        (ressource != null && ressource.username == username)) {
      return true;
    }

    if (!strict) {
      return permissionsNeeded.any(permissions.contains);
    }

    return permissionsNeeded.every(permissions.contains);
  }
}
