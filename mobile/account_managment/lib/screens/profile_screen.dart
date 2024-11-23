import 'package:account_managment/forms/profile_form.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  String action;

  ProfileScreen({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$action your account".capitalize())),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProfileForm(
            action: action,
          )),
    );
  }
}
