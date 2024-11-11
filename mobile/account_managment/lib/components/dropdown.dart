import 'dart:convert';

import 'package:account_managment/models/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Dropdown extends StatefulWidget {
  final Function selectAccount;
  const Dropdown({super.key, required this.selectAccount});

  @override
  _DropdownState createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String dropdownValue = "";
  final List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    _retrieveList();
  }

  Future<void> _retrieveList() async {
    final token = await const FlutterSecureStorage().read(key: 'accessToken');

    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/accounts/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      setState(() {
        for (var account in jsonDecode(response.body)) {
          accounts.add(Account(id: account["id"], name: account["name"]));
        }
      });
      widget.selectAccount(accounts.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return DropdownButton<String>(
        items: const [
          DropdownMenuItem(
            value: null,
            child: Text("No accounts available"),
          ),
        ],
        onChanged: (value) {},
      );
    }
    return DropdownMenu<Account>(
      initialSelection: accounts.first,
      onSelected: (Account? value) {
        setState(() {
          dropdownValue = accounts.first.name;
          widget.selectAccount(value);
        });
      },
      dropdownMenuEntries:
          accounts.map<DropdownMenuEntry<Account>>((Account value) {
        return DropdownMenuEntry<Account>(value: value, label: value.name);
      }).toList(),
    );
  }
}
