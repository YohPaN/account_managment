class CategoryApp {
  int id;
  String title;
  String color;

  CategoryApp({
    required this.id,
    required this.title,
    required this.color,
  });

  static CategoryApp deserialize(jsonCategory) {
    return CategoryApp(
      id: jsonCategory["id"],
      title: jsonCategory["title"],
      color: jsonCategory["color"],
    );
  }
}
