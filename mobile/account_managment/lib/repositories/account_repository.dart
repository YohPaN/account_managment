import 'dart:convert';

import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';

import '../models/account.dart';
import 'package:http/http.dart' as http;

class AccountRepository {
  final AuthViewModel authViewModel;

  AccountRepository({required this.authViewModel});

  Future<List<Account>> list() async {
    final List<Account> accounts = [];

    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/accounts/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.accessToken}'
        });

    if (response.statusCode == 200) {
      for (var account in jsonDecode(response.body)) {
        final List<Item> items = [];

        for (var item in account["items"]) {
          items.add(Item(
              id: item["id"],
              title: item["title"],
              description: item["description"],
              valuation: double.parse(item["valuation"])));
        }

        final List<Contributor> contributors = [];

        for (var contributor in account["contributors"]) {
          contributors.add(
            Contributor(
              username: contributor["user"]["username"],
              state: contributor["state"],
            ),
          );
        }

        accounts.add(
          Account(
            id: account["id"],
            name: account["name"],
            items: items,
            contributor: contributors,
            total: account["total"]["total_sum"],
          ),
        );
      }
    }

    return accounts;
  }

  Future<Account?> get(int? accountId) async {
    http.Response response;

    if (accountId != null) {
      response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/accounts/$accountId/'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authViewModel.accessToken}'
          });
    } else {
      response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/accounts/me/'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authViewModel.accessToken}'
          });
    }

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<Item> items = [];

      for (var item in responseData["items"]) {
        items.add(Item(
            id: item["id"],
            title: item["title"],
            description: item["description"],
            valuation: double.parse(item["valuation"])));
      }

      final List<Contributor> contributors = [];

      for (var contributor in responseData["contributor"]) {
        contributors.add(
          Contributor(
            username: contributor["user"]["username"],
            state: contributor["state"],
          ),
        );
      }

      return Account(
        id: responseData["id"],
        name: responseData["name"],
        items: items,
        contributor: contributors,
        total: responseData["valuation"],
      );
    }

    return null;
  }

  Future<bool?> create(String name, List<Contributor> contributors) async {
    final List<String> contributorSerializable = [];

    for (var contributor in contributors) {
      contributorSerializable.add(contributor.username);
    }

    final response =
        await http.post(Uri.parse('http://10.0.2.2:8000/api/accounts/'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${authViewModel.accessToken}'
            },
            body: jsonEncode(<String, String>{
              'name': name,
              'contributors': jsonEncode(contributorSerializable),
            }));

    if (response.statusCode == 201) {
      return true;
    }

    return null;
  }

  Future<bool?> update(
      int accountId, String name, List<Contributor> contributors) async {
    final List<String> contributorSerializable = [];

    for (var contributor in contributors) {
      contributorSerializable.add(contributor.username);
    }

    final response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/api/accounts/$accountId/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.accessToken}'
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'contributors': jsonEncode(contributorSerializable)
        }));

    if (response.statusCode == 200) {
      return true;
    }

    return null;
  }

  Future<bool?> delete(int accountId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/accounts/$accountId/'),
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
