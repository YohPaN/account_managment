import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';

class Account {
  int id;
  String name;
  bool isMain;
  List<Item> items;
  List<Contributor> contributor;
  double? total;

  Account({
    required this.id,
    required this.name,
    required this.isMain,
    required this.items,
    required this.contributor,
    this.total,
  });

  static Account deserialize(jsonAccount) {
    return Account(
      id: jsonAccount["id"],
      name: jsonAccount["name"],
      isMain: jsonAccount["is_main"],
      items: [],
      contributor: [],
      total: jsonAccount["total"]["total_sum"],
    );
  }
}
