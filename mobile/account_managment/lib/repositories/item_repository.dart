import 'dart:convert';
import 'package:account_managment/common/api_config.dart';
import 'package:account_managment/helpers/request_handler.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:http/http.dart' as http;

class ItemRepository {
  Future<bool?> create(
      String title, String description, String valuation, int accountId) async {
    final RepoResponse repoResponse = await RequestHandler.handleRequest(
        method: "POST",
        uri: "items/",
        contentType: 'application/json',
        body: {
          'account': accountId.toString(),
          'title': title,
          'description': description,
          'valuation': valuation,
        });

    return null;
  }

  Future<bool?> update(
      int itemId, String title, String description, String valuation) async {
    final response = await http.patch(
        Uri.parse(
            'http://${APIConfig.base_url}:${APIConfig.port}/api/items/$itemId/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
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
      Uri.parse(
          'http://${APIConfig.base_url}:${APIConfig.port}/api/items/$itemId/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    }

    return null;
  }
}
