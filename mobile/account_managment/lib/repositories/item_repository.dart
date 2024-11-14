import 'dart:convert';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:http/http.dart' as http;

class ItemRepository {
  final AuthViewModel authViewModel;
  final AccountViewModel accountViewModel;

  ItemRepository({required this.authViewModel, required this.accountViewModel});

  Future<bool?> create(
      String title, String description, String valuation) async {
    final response =
        await http.post(Uri.parse('http://10.0.2.2:8000/api/items/'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${authViewModel.accessToken}'
            },
            body: jsonEncode(<String, String>{
              'account': accountViewModel.account!.id.toString(),
              'title': title,
              'description': description,
              'valuation': valuation,
            }));

    if (response.statusCode == 201) {
      return true;
    }

    return null;
  }

  Future<bool?> update(
      int itemId, String title, String description, String valuation) async {
    final response =
        await http.patch(Uri.parse('http://10.0.2.2:8000/api/items/$itemId/'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${authViewModel.accessToken}'
            },
            body: jsonEncode(<String, String>{
              'title': title,
              'description': description,
              'valuation': valuation,
            }));

    if (response.statusCode == 200) {
      return true;
    }

    return null;
  }

  Future<List<Item>?> list(int accountId) async {
    final List<Item> items = [];

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/accounts/$accountId/items/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authViewModel.accessToken}'
      },
    );

    if (response.statusCode == 200) {
      for (var item in jsonDecode(response.body)) {
        items.add(Item(
            id: item["id"],
            title: item["title"],
            description: item["description"],
            valuation: item["valuation"]));
      }

      return items;
    }

    return null;
  }

  Future<bool?> delete(int itemId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/items/$itemId/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authViewModel.accessToken}'
      },
    );

    if (response.statusCode == 200) {
      return true;
    }

    return null;
  }
}
