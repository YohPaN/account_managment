import 'dart:convert';

import 'package:account_managment/login.dart';
import 'package:account_managment/my_accounts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthRedirector extends StatelessWidget {
  const AuthRedirector({super.key});

  Future<bool> checkLoginStatus() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/is_logged/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final data = jsonDecode(response.body);

    return data["is_logged"];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error checking login status')),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return const MyAccounts();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
