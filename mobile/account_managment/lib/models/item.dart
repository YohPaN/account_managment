class Item {
  int id;
  String title;
  String description;
  String? username;
  double valuation;
  Map<String, String?>? toAccount;

  Item({
    required this.id,
    required this.title,
    required this.description,
    this.username,
    this.toAccount,
    required this.valuation,
  });

  static Item deserialize(jsonItem) {
    return Item(
        id: jsonItem["id"],
        title: jsonItem["title"],
        description: jsonItem["description"],
        username: jsonItem["user"] != null ? jsonItem["user"]["username"] : "",
        valuation: double.parse(
          jsonItem["valuation"],
        ),
        toAccount: {
          "id": jsonItem["to_account"]["id"].toString(),
          "name": jsonItem["to_account"]["name"]
        });
  }
}
