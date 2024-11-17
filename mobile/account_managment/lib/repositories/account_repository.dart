import 'dart:convert';

import 'package:account_managment/models/contributor.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';

import '../models/account.dart';
import 'package:http/http.dart' as http;

class AccountRepository {
  final AuthViewModel authViewModel;

  AccountRepository({required this.authViewModel});

  Future<Map<String, List<Account>>> list() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/accounts/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.accessToken}'
        });

    final List<Account> accounts = [];
    final List<Account> contributorAccounts = [];

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      for (var account in responseData["own"]) {
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
            isMain: account["is_main"],
            items: items,
            contributor: contributors,
            total: account["total"]["total_sum"],
          ),
        );
      }

      for (var contributorAccount in responseData["contributor_account"]) {
        final List<Item> items = [];

        for (var item in contributorAccount["items"]) {
          items.add(Item(
              id: item["id"],
              title: item["title"],
              description: item["description"],
              valuation: double.parse(item["valuation"])));
        }

        final List<Contributor> contributors = [];
        for (var contributor in contributorAccount["contributors"]) {
          contributors.add(
            Contributor(
              username: contributor["user"]["username"],
              state: contributor["state"],
            ),
          );
        }

        contributorAccounts.add(
          Account(
            id: contributorAccount["id"],
            name: contributorAccount["name"],
            isMain: contributorAccount["is_main"],
            items: items,
            contributor: contributors,
            total: contributorAccount["total"]["total_sum"],
          ),
        );
      }
    }

    return {"accounts": accounts, "contributorAccounts": contributorAccounts};
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

      for (var contributor in responseData["contributors"]) {
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
        isMain: responseData["is_main"],
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
