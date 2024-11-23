class Item {
  int id;
  String title;
  String description;
  double valuation;

  Item(
      {required this.id,
      required this.title,
      required this.description,
      required this.valuation});

  static Item deserialize(jsonItem) {
    return Item(
      id: jsonItem["id"],
      title: jsonItem["title"],
      description: jsonItem["description"],
      valuation: double.parse(
        jsonItem["valuation"],
      ),
    );
  }
}
