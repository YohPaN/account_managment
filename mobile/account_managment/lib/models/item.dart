import 'package:account_managment/models/base_model.dart';
import 'package:account_managment/models/category.dart';

class Item extends BaseModel {
  int id;
  String title;
  String? description;
  String? username;
  CategoryApp? category;
  double valuation;
  Map<String, String?>? toAccount;
  bool transfertItem;

  Item({
    required this.id,
    required this.title,
    required this.description,
    this.username,
    this.category,
    this.toAccount,
    required this.valuation,
    required this.transfertItem,
  }) : super.fromJson({});

  factory Item.fromJson(json, isTransfertItem) {
    return Item(
      id: json["id"],
      description: json["description"],
      title: json["title"],
      toAccount: {
        "id": json["to_account"]["id"]?.toString(),
        "name": json["to_account"]["name"]?.toString()
      },
      transfertItem: isTransfertItem ?? false,
      username: json["user"] != null ? json["user"]["username"] : "",
      valuation: double.parse(
        json["valuation"],
      ),
    );
  }
}
