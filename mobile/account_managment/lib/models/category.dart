import 'dart:convert';

import 'package:account_managment/models/base_model.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class CategoryApp extends BaseModel {
  int id;
  String title;
  int? color;
  IconPickerIcon? icon;

  CategoryApp({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
  }) : super.fromJson({});

  factory CategoryApp.fromJson(Map<String, dynamic> json, dynamic other) {
    return CategoryApp(
      id: json["id"],
      title: json["title"],
      color: json["color"] != "" ? int.parse(json["color"]) : null,
      icon: deserializeIcon(json["icon"].runtimeType == String
          ? jsonDecode(json["icon"])
          : json["icon"]),
    );
  }

  void update(data) {
    title = data["title"];
    color = int.parse(data["color"]);
    icon = deserializeIcon(data["icon"].runtimeType == String
        ? jsonDecode(data["icon"])
        : data["icon"]);
  }
}
