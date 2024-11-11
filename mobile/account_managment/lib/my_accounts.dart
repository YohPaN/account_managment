import 'dart:convert';

import 'package:account_managment/components/bottom_bar.dart';
import 'package:account_managment/components/create_item.dart';
import 'package:account_managment/components/dropdown.dart';
import 'package:account_managment/components/list_item.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MyAccounts extends StatefulWidget {
  const MyAccounts({super.key});

  @override
  _MyAccountsState createState() => _MyAccountsState();
}

class _MyAccountsState extends State<MyAccounts> {
  final List itemList = [];

  Account? selectedAccount;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _retrieveList(int accountId) async {
    final token = await const FlutterSecureStorage().read(key: 'accessToken');

    final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/accounts/$accountId/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      setState(() {
        itemList.clear();
        for (var item in responseData["items"]) {
          itemList.add(Item(
              id: item["id"],
              title: item["title"],
              description: item["description"],
              valuation: item["valuation"]));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fail to retrieve items"),
          backgroundColor: Color.fromRGBO(255, 0, 0, 1),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2), // Customize duration as needed
          margin: EdgeInsets.only(
              bottom: 50.0,
              left: 20.0,
              right: 20.0), // Adjust margins for positioning
        ),
      );
    }
  }

  selectAccount(Account account) {
    setState(() {
      selectedAccount = account;
      _retrieveList(account.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(selectedAccount != null ? selectedAccount!.name : ""),
                  Container(child: Dropdown(selectAccount: selectAccount))
                ],
              ),
            ),
            if (selectedAccount != null)
              Expanded(
                child: ListView.builder(
                  itemCount: itemList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: ListItem(
                              item: itemList[index],
                              callbackFn: _retrieveList,
                              accountId: selectedAccount!.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedAccount != null
            ? () => showBottomDrawer(
                context: context,
                accountId: selectedAccount!.id,
                closeCallback: _retrieveList,
                createOrUpdate: "create")
            : null,
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.add),
      ),
    );
  }
}
