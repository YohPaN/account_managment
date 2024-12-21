import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';

class Account {
  int id;
  String name;
  bool isMain;
  List<Item> items;
  double? ownContribution;
  List<Contributor> contributor;
  List<dynamic> permissions;
  String user;
  double? total;

  Account({
    required this.id,
    required this.name,
    required this.isMain,
    required this.items,
    this.ownContribution,
    required this.contributor,
    required this.permissions,
    required this.user,
    this.total,
  });

  static Account deserialize(jsonAccount) {
    return Account(
      id: jsonAccount["id"],
      name: jsonAccount["name"],
      isMain: jsonAccount["is_main"],
      items: [],
      ownContribution: jsonAccount["own_contribution"] != null
          ? jsonAccount["own_contribution"]["total"]
          : null,
      contributor: [],
      permissions: jsonAccount["permissions"],
      user: jsonAccount["user"]["username"],
      total: jsonAccount["total"]["total_sum"],
    );
  }
}
