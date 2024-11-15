import 'package:account_managment/forms/password_form.dart';
import 'package:flutter/material.dart';

class PasswordDrawerState extends StatelessWidget {
  final String action;

  const PasswordDrawerState({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
          child: PasswordForm(
        action: action,
      )),
    );
  }
}
