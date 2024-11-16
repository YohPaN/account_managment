import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          child: const Text("Logout"),
          onPressed: () {
            authViewModel.logout();
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/",
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
