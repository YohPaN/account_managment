import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';

class Account {
  int id;
  String name;
  bool isMain;
  List<Item> items;
  double? ownContribution;
  double? needToAdd;
  List<CategoryApp> categories;
  List<CategoryApp> accountCategories;
  List<Contributor> contributor;
  List<String> permissions;
  String username;
  double total;
  bool salaryBasedSplit;

  Account({
    required this.id,
    required this.name,
    required this.isMain,
    required this.items,
    required this.categories,
    required this.accountCategories,
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
      categories: [],
      accountCategories: [],
      permissions: List<String>.from(jsonAccount["permissions"]),
      username: jsonAccount["user"]["username"],
      total: jsonAccount["total"]["total_sum"],
      salaryBasedSplit: jsonAccount["salary_based_split"],
    );
  }

  Future<void> update(data) async {
    if (data["name"] != null) name = data["name"];
    if (data["salary_based_split"] != null) {
      salaryBasedSplit = data["salary_based_split"];
    }
    if (data["contributors"] != null) {
      contributor = [];

      for (var contributor in data["contributors"]) {
        this.contributor.add(Contributor.deserialize(contributor));
      }
    }
  }
}
