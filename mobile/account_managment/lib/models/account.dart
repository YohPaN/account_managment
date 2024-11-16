import 'package:account_managment/models/item.dart';

class Account {
  int id;
  String name;
  List<Item> items;
  double? total;

  Account({
    required this.id,
    required this.name,
    required this.items,
    this.total,
  });
}
