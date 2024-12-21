class Item {
  int id;
  String title;
  String description;
  String? username;
  double valuation;

  Item(
      {required this.id,
      required this.title,
      required this.description,
      this.username,
      required this.valuation});

  static Item deserialize(jsonItem) {
    return Item(
      id: jsonItem["id"],
      title: jsonItem["title"],
      description: jsonItem["description"],
      username: jsonItem["user"]["username"] ?? "",
      valuation: double.parse(
        jsonItem["valuation"],
      ),
    );
  }
}
