import 'package:account_managment/common/model_factory.dart';
import 'package:account_managment/models/base_model.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/contributor.dart';

class Account extends BaseModel {
  int id;
  List<CategoryApp> accountCategories;
  List<CategoryApp> categories;
  List<Contributor> contributor;
  bool isMain;
  List<dynamic> items;
  String name;
  double? needToAdd;
  double? ownContribution;
  List<String> permissions;
  bool salaryBasedSplit;
  double total;
  String username;

  Account({
    required this.id,
    required this.accountCategories,
    required this.categories,
    required this.contributor,
    required this.isMain,
    required this.items,
    required this.name,
    this.needToAdd,
    this.ownContribution,
    required this.permissions,
    required this.salaryBasedSplit,
    required this.total,
    required this.username,
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
            other: {"isTransfertItem": true},
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
    for (var field in data.keys) {
      switch (field) {
        case "contributors":
          this.contributor = [];

          for (var contributorRequest in data["contributors"]) {
            this.contributor.add(ModelFactory.fromJson(
                json: contributorRequest, type: 'contributor'));
          }

        case "name":
          this.name = data["name"];

        case "salary_based_split":
          this.salaryBasedSplit = data["salary_based_split"];

        default:
      }
    }
  }
}
