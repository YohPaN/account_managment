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
      accountName: jsonAccountUser["account_name"],
      adminUsername: jsonAccountUser["account_owner_username"],
    );
  }
}
