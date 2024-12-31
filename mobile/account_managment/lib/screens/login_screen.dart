import 'package:account_managment/common/navigation_index.dart';
import 'package:account_managment/forms/login_form.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthViewModel>(context, listen: false).verifToken(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (!snapshot.data!) {
            return Scaffold(
              appBar: AppBar(title: const Text("Login")),
              body: const Padding(
                padding: EdgeInsets.all(16.0),
                child: LoginForm(),
              ),
            );
          } else {
            Provider.of<NavigationIndex>(context, listen: false).changeIndex(0);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            });
            return const SizedBox();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
