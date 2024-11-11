import 'dart:convert';

import 'package:account_managment/components/input_text_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CreateAccount extends StatefulWidget {
  final String createOrUpdate;

  const CreateAccount({super.key, required this.createOrUpdate});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAccountData(); // Call the function to fetch user data when the widget is initialized
  }

  Future<void> _fetchAccountData() async {
    if (widget.createOrUpdate == "update") {
      const accountId = 1;
      try {
        final token =
            await const FlutterSecureStorage().read(key: 'accessToken');

        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/accounts/$accountId/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          setState(() {
            _nameController.text = data['username'] ?? '';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to load user data"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Define your function here
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final token = await const FlutterSecureStorage().read(key: 'accessToken');

      if (widget.createOrUpdate == "create") {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/accounts/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String, String>{
            'name': _nameController.text,
          }),
        );

        if (response.statusCode == 201) {
          Navigator.pop(context);
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
      } else if (widget.createOrUpdate == "update") {
        const accountId = 1;

        final response = await http.patch(
          Uri.parse('http://10.0.2.2:8000/api/accounts/$accountId/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String, String>{
            'name': _nameController.text,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cannot update profile"),
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
                  controller: _nameController,
                  name: "name",
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
                              Color.fromARGB(255, 167, 33, 33)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
                        ),
                      ),
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                              Color.fromARGB(255, 33, 116, 36)),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _handleSubmit();
                          }
                        },
                        child: Text(
                          "${widget.createOrUpdate} an account",
                          style: const TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1)),
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
