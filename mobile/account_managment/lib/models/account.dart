import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';

class Account {
  int id;
  String name;
  bool isMain;
  List<Item> items;
  double? ownContribution;
  double? needToAdd;
  List<Contributor> contributor;
  List<dynamic> permissions;
  String username;
  double total;
  bool? salaryBasedSplit;

  Account({
    required this.id,
    required this.name,
    required this.isMain,
    required this.items,
    this.ownContribution,
    this.needToAdd,
    required this.contributor,
    required this.permissions,
    required this.username,
    required this.salaryBasedSplit,
    required this.total,
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
      needToAdd: jsonAccount["need_to_add"] != null
          ? jsonAccount["need_to_add"]["total"]
          : null,
      contributor: [],
      permissions: jsonAccount["permissions"],
      username: jsonAccount["user"]["username"],
      total: jsonAccount["total"]["total_sum"],
      salaryBasedSplit: jsonAccount["salary_based_split"],
    );
  }
}
