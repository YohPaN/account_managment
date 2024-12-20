class AccountUser {
  int id;
  String accountName;
  String adminUsername;

  AccountUser({
    required this.id,
    required this.accountName,
    required this.adminUsername,
  });

  static AccountUser deserialize(jsonAccountUser) {
    return AccountUser(
      id: jsonAccountUser["id"],
      accountName: jsonAccountUser["account"]["name"],
      adminUsername: jsonAccountUser["account"]["user"]["username"],
    );
  }
}
