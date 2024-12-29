class Item {
  int id;
  String title;
  String description;
  String? username;
  double valuation;
  Map<String, String?>? toAccount;
  bool transfertItem = false;

  Item({
    required this.id,
    required this.title,
    required this.description,
    this.username,
    this.toAccount,
    required this.valuation,
    required this.transfertItem,
  });

  static Item deserialize(jsonItem, [isTransfertItem]) {
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
          "id": jsonItem["to_account"]["id"].toString(),
          "name": jsonItem["to_account"]["name"]
        });
  }
}
