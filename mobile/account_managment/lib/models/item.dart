import 'package:account_managment/models/category.dart';

class Item {
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
  });

  static Item deserialize(jsonItem, [isTransfertItem = false]) {
    return Item(
        id: jsonItem["id"],
        title: jsonItem["title"],
        description: jsonItem["description"],
        username: jsonItem["user"] != null ? jsonItem["user"]["username"] : "",
        valuation: double.parse(
          jsonItem["valuation"],
        ),
        transfertItem: isTransfertItem,
        toAccount: {
          "id": jsonItem["to_account"]["id"]?.toString(),
          "name": jsonItem["to_account"]["name"]
        });
  }
}
