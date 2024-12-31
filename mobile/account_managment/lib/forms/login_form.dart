import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/common/navigation_index.dart';
import 'package:account_managment/components/icon_visibility.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
                labelText: 'Password',
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
                      context, '/home', (route) => false);
                } else {
                  passwordController.text = "";
                  Provider.of<InternalNotification>(context, listen: false)
                      .showMessage(error, success);
                }
              },
              child: const Text("Login"),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              usernameController.text = "";
              Navigator.pushNamed(context, '/register');
            },
            child: const Text("Create account"),
          ),
        ],
      ),
    );
  }
}
