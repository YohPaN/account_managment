import 'dart:convert';

import 'package:account_managment/models/item.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';

import '../models/account.dart';
import 'package:http/http.dart' as http;

class AccountRepository {
  final AuthViewModel authViewModel;

  AccountRepository({required this.authViewModel});

  Future<List<Account>> listAccounts() async {
    final List<Account> accounts = [];

    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/accounts/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.accessToken}'
        });

    if (response.statusCode == 200) {
      for (var account in jsonDecode(response.body)) {
        accounts.add(Account(
            id: account["id"], name: account["name"], items: account["items"]));
      }
    }

    return accounts;
  }

  Future<Account?> getAccount(int accountId) async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/accounts/$accountId/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authViewModel.accessToken}'
        });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<Item> items = [];

      for (var item in responseData["items"]) {
        items.add(Item(
            id: item["id"],
            title: item["title"],
            description: item["description"],
            valuation: item["valuation"]));
      }
      return Account(
          id: responseData["id"], name: responseData["name"], items: items);
    }

    return null;
  }

  Future<void> addAccount(Account account) async {
    // Simulate adding an account
  }
}
