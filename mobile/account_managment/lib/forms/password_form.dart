import 'package:account_managment/components/password_field.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordForm extends StatefulWidget {
  final String action;

  const PasswordForm({super.key, required this.action});

  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    Future<void> saveForm() async {
      _formKey.currentState!.save();
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          PasswordField(
            label: "Old password",
            index: "oldPassword",
            formData: _formData,
          ),
          PasswordField(
            label: "New password",
            index: "newPassword",
            formData: _formData,
            comparisonDiff: "oldPassword",
          ),
          PasswordField(
            label: "Retype password",
            index: "retypePassword",
            formData: _formData,
            comparisonSame: "newPassword",
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await saveForm();
                  if (_formKey.currentState!.validate()) {
                    profileViewModel.updatePassword(
                      _formData["oldPassword"]!,
                      _formData["newPassword"]!,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('${widget.action} password'.capitalize()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
