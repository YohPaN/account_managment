import 'package:account_managment/common/model_factory.dart';
import 'package:account_managment/models/base_model.dart';
import 'package:account_managment/models/category.dart';

class Item extends BaseModel {
  int id;
  CategoryApp? category;
  String? description;
  String title;
  Map<String, dynamic>? toAccount;
  bool transfertItem;
  String? username;
  double valuation;

  Item({
    required this.id,
    this.category,
    required this.description,
    required this.title,
    this.toAccount,
    required this.transfertItem,
    this.username,
    required this.valuation,
  }) : super.fromJson({});

  factory Item.fromJson(json, isTransfertItem) {
    return Item(
      id: json["id"],
      category: json["category"] != null
          ? ModelFactory.fromJson(json: json["category"], type: 'category')
          : null,
      description: json["description"],
      title: json["title"],
      toAccount: {
        "id": json["to_account"]["id"]?.toString(),
        "name": json["to_account"]["name"]?.toString()
      },
      transfertItem: isTransfertItem ?? false,
      username: json["user"] != null ? json["user"]["username"] : null,
      valuation: double.parse(
        json["valuation"],
      ),
    );
  }

  Future<void> update(data) async {
    for (var field in data.keys) {
      switch (field) {
        case "title":
          this.title = data["title"];

        case "description":
          this.description = data["description"];

        case "valuation":
          this.valuation = double.parse(
            data["valuation"],
          );

        case "user":
          this.username =
              data["user"] != null ? data["user"]["username"] : null;

        case "to_account":
          this.toAccount = data["to_account"];

        // case "category":
        //   this.category = data["category"];

        default:
      }
    }
  }
}
