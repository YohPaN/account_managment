class CategoryApp {
  int id;
  String title;
  int? color;
  int? icon;

  CategoryApp({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
  });

  static CategoryApp deserialize(jsonCategory) {
    return CategoryApp(
      id: jsonCategory["id"],
      title: jsonCategory["title"],
      color:
          jsonCategory["color"] != "" ? int.parse(jsonCategory["color"]) : null,
      icon: jsonCategory["icon"] != "" ? int.parse(jsonCategory["icon"]) : null,
    );
  }

  void update(data) {
    title = data["title"];
    color = int.parse(data["color"]);
    icon = int.parse(data["icon"]);
  }
}
