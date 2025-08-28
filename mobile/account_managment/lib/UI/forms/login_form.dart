import 'package:account_managment/helpers/internal_notification_helper.dart';
import 'package:account_managment/helpers/navigation_index_helper.dart';
import 'package:account_managment/UI/components/icon_visibility.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _passwordVisibility = true;

  @override
  void initState() {
    super.initState();
    _loadLastUsername();
  }

  Future<void> _loadLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUsername = prefs.getString('last_username');

    if (lastUsername != null) {
      setState(() {
        usernameController.text = lastUsername;
      });
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      _passwordVisibility = !_passwordVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = AuthViewModel();
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            decoration:
                InputDecoration(labelText: locale.username.capitalize()),
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
                labelText: locale.password.capitalize(),
                suffixIcon: IconButton(
                    onPressed: () => togglePasswordVisibility(),
                    icon: IconVisibility(visibility: _passwordVisibility))),
            obscureText: _passwordVisibility,
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.ltr,
            child: ElevatedButton(
              onPressed: () async {
                var [success, error] = await authViewModel.login(
                  usernameController.text,
                  passwordController.text,
                );
                if (success == true) {
                  Provider.of<NavigationIndex>(context, listen: false)
                      .changeIndex(0);

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                      'last_username', usernameController.text);

                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/splash', (route) => false);
                } else {
                  passwordController.text = "";
                  Provider.of<InternalNotification>(context, listen: false)
                      .showMessage(error, success);
                }
              },
              child: Text(locale.login.capitalize()),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              usernameController.text = "";
              Navigator.pushNamed(context, '/register');
            },
            child: Text(
                "${locale.action("create").capitalize()} ${locale.possessive("your")} ${locale.account("")}"),
          ),
        ],
      ),
    );
  }
}
