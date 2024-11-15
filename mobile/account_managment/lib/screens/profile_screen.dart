import 'package:account_managment/forms/profile_form.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final action =
        (args != null && args['update'] == true) ? 'update' : 'create';

    return Scaffold(
      appBar: AppBar(title: Text("$action your account")),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProfileForm(
            action: action,
          )),
    );
  }
}
