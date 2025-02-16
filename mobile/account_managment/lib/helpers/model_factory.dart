import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/category.dart';
import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';

class ModelFactory {
  static dynamic fromJson({
    required dynamic json,
    required String type,
    Map<String, dynamic> other = const {},
  }) {
    try {
      switch (type) {
        case 'account':
          return listDeserialize(json, Account.fromJson);

        case 'category':
          return listDeserialize(json, CategoryApp.fromJson);

        case 'contributor':
          return listDeserialize(json, Contributor.fromJson);

        case 'item':
          return listDeserialize(json, Item.fromJson, other["isTransfertItem"]);

        default:
          throw Exception("Type inconnu : $type");
      }
    } catch (e) {
      print("error: $e");
      throw Exception(
          "An error occured with type $type. Data was $json \nError was : $e");
    }
  }

  static listDeserialize(json, fromJson, [other]) {
    if (json.runtimeType == List) {
      return json.map((e) => fromJson(e, other)).toList();
    } else {
      return fromJson(json, other);
    }
  }
}
