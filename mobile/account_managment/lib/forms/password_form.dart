import 'package:account_managment/components/password_field.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final AppLocalizations locale = AppLocalizations.of(context)!;

    Future<void> saveForm() async {
      _formKey.currentState!.save();
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          PasswordField(
            label: locale.actual_password.capitalize(),
            index: "oldPassword",
            formData: _formData,
          ),
          PasswordField(
            label: locale.new_password.capitalize(),
            index: "newPassword",
            formData: _formData,
            comparisonDiff: "oldPassword",
          ),
          PasswordField(
            label: locale.retype_password.capitalize(),
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
                child: Text(locale.back.capitalize()),
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
                child: Text(locale.action_password(widget.action).capitalize()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
