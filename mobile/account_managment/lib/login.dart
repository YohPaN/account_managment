import 'dart:convert';

import 'package:account_managment/components/input_text_form.dart';
import 'package:account_managment/create_profile.dart';
import 'package:account_managment/my_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Define your function here
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/token/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access'];
        final refreshToken = responseData['refresh'];

        // Store the token securely
        await const FlutterSecureStorage()
            .write(key: 'accessToken', value: accessToken);
        await const FlutterSecureStorage()
            .write(key: 'refreshToken', value: refreshToken);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MyAccounts()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Wrong login"),
            backgroundColor: Color.fromRGBO(255, 0, 0, 1),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2), // Customize duration as needed
            margin: EdgeInsets.only(
                bottom: 50.0,
                left: 20.0,
                right: 20.0), // Adjust margins for positioning
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Form(
          key: _formKey,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centers the form vertically
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InputTextForm(
                  controller: _usernameController,
                  name: "username",
                  isRequired: true,
                ),
                InputTextForm(
                  controller: _passwordController,
                  name: "password",
                  isRequired: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                              Color.fromARGB(255, 38, 82, 148)),
                        ),
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CreateProfile(
                                      createOrUpdate: 'create')));
                        },
                        child: const Text(
                          'Create an account',
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
                        ),
                      ),
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                              Color.fromARGB(255, 33, 116, 36)),
                        ),
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          if (_formKey.currentState!.validate()) {
                            _handleSubmit();
                          }
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
