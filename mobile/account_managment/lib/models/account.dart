import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';

class Account {
  int id;
  String name;
  List<Item> items;
  List<Contributor> contributor;
  double? total;

  Account({
    required this.id,
    required this.name,
    required this.items,
    required this.contributor,
    this.total,
  });
}
