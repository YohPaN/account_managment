import 'dart:convert';
import 'package:account_managment/common/api_config.dart';
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
        await http.post(Uri.parse('http://${APIConfig.base_url}:${APIConfig.port}/api/items/'),
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
        await http.patch(Uri.parse('http://${APIConfig.base_url}:${APIConfig.port}/api/items/$itemId/'),
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

  Future<bool?> delete(int itemId) async {
    final response = await http.delete(
      Uri.parse('http://${APIConfig.base_url}:${APIConfig.port}/api/items/$itemId/'),
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
