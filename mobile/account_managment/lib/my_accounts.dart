import 'dart:convert';

import 'package:account_managment/components/bottom_bar.dart';
import 'package:account_managment/components/create_item.dart';
import 'package:account_managment/components/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MyAccounts extends StatefulWidget {
  const MyAccounts({super.key});

  @override
  _MyAccountsState createState() => _MyAccountsState();
}

class Item {
  String title;
  String description;
  String valuation;

  Item(
      {required this.title,
      required this.description,
      required this.valuation});
}

class Account {
  int id;
  String name;

  Account({
    required this.id,
    required this.name,
  });
}

class _MyAccountsState extends State<MyAccounts> {
  final List itemList = [];

  late Account account = Account(id: 0, name: "");

  @override
  void initState() {
    super.initState();
    _retrieveList();
  }

  Future<void> _retrieveList() async {
    final token = await const FlutterSecureStorage().read(key: 'accessToken');

    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/item/'),
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
              title: item["title"],
              description: item["description"],
              valuation: item["valuation"]));
        }

        account = Account(
          id: responseData["account"]["id"],
          name: responseData["account"]["name"],
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(account.name),
            ),
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
                        title: ListItem(item: itemList[index]),
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
        onPressed: () => showBottomDrawer(context, account.id, _retrieveList),
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.add),
      ),
    );
  }
}
