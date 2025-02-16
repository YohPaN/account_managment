import 'package:account_managment/helpers/model_factory.dart';
import 'package:account_managment/models/base_model.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/contributor.dart';

class Account extends BaseModel {
  int id;
  String name;
  bool isMain;
  List<dynamic> items;
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
  }) : super.fromJson({});

  factory Account.fromJson(json, other) {
    return Account(
      id: json["id"],
      accountCategories: [
        ...ModelFactory.fromJson(
            json: json["account_categories"], type: "category")
      ],
      categories: [
        ...ModelFactory.fromJson(json: json["categories"], type: "category")
      ],
      contributor: [
        ...ModelFactory.fromJson(
            json: json["contributors"], type: "contributor")
      ],
      isMain: json["is_main"],
      items: [
        ...ModelFactory.fromJson(
          json: json["items"],
          type: "item",
          other: {"isTransfertItem": false},
        ),
        if (json["transfer_items"] != null)
          ...ModelFactory.fromJson(
            json: json["transfer_items"],
            type: "item",
            other: {"isTransfertItem": false},
          )
      ],
      name: json["name"],
      needToAdd:
          json["need_to_add"] != null ? json["need_to_add"]["total"] : null,
      ownContribution: json["own_contribution"] != null
          ? json["own_contribution"]["total"]
          : null,
      permissions: List<String>.from(json["permissions"]),
      salaryBasedSplit: json["salary_based_split"],
      total: double.parse(json["total"]),
      username: json["user"]["username"],
    );
  }

  Future<void> update(data) async {
    if (data["name"] != null) name = data["name"];
    if (data["salary_based_split"] != null) {
      salaryBasedSplit = data["salary_based_split"];
    }
    if (data["contributors"] != null) {
      this.contributor = [];

      for (var contributorRequest in data["contributors"]) {
        this.contributor.add(ModelFactory.fromJson(
            json: contributorRequest, type: 'contributor'));
      }
    }
  }
}
