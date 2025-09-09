import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:account_managment/UI/forms/login_form.dart';
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
              appBar: AppBar(
                  title:
                      Text(AppLocalizations.of(context)!.login.capitalize())),
              body: const Padding(
                padding: EdgeInsets.all(16.0),
                child: LoginForm(),
              ),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/splash', (route) => false);
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
