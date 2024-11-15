import 'package:account_managment/forms/login_form.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: LoginForm(),
      ),
    );
  }
}
