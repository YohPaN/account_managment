import 'package:account_managment/components/icon_visibility.dart';
import 'package:account_managment/viewModels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void togglePasswordVisibility() {
    setState(() {
      _passwordVisibility = !_passwordVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

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
                    icon: IconVisibility(visibility: _passwordVisibility!))),
            obscureText: _passwordVisibility,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await authViewModel.login(
                usernameController.text,
                passwordController.text,
              );
              if (authViewModel.accessToken != null) {
                Navigator.pushReplacementNamed(context, '/accounts');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid credentials")),
                );
              }
            },
            child: const Text("Login"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: const Text("Create account"),
          ),
        ],
      ),
    );
  }
}