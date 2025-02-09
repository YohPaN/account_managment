import 'package:flutter_iconpicker/Models/icon_picker_icon.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class CategoryApp {
  int id;
  String title;
  int? color;
  IconPickerIcon? icon;

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
        color: jsonCategory["color"] != ""
            ? int.parse(jsonCategory["color"])
            : null,
        icon: deserializeIcon(jsonCategory["icon"]));
  }

  void update(data) {
    title = data["title"];
    color = int.parse(data["color"]);
    icon = deserializeIcon(data["icon"]);
  }
}
