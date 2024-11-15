import 'package:account_managment/components/icon_visibility.dart';
import 'package:account_managment/helpers/pwd_validation_helper.dart';
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

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController retypePasswordController =
      TextEditingController();
  final Map<String, bool> _passwordVisibility = {
    "old": true,
    "new": true,
    "retype": true,
  };

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    void togglePasswordVisibility(String key) {
      setState(() {
        _passwordVisibility[key] = !_passwordVisibility[key]!;
      });
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.action == "update")
            TextFormField(
              controller: oldPasswordController,
              decoration: InputDecoration(
                labelText: 'Old password',
                suffixIcon: IconButton(
                    onPressed: () => togglePasswordVisibility("old"),
                    icon: IconVisibility(
                        visibility: _passwordVisibility["old"]!)),
              ),
              maxLength: 50,
              obscureText: _passwordVisibility["old"]!,
              validator: (value) => PwdValidationHelper.validatePassword(
                password: value!,
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: newPasswordController,
            decoration: InputDecoration(
              labelText: 'New password',
              suffixIcon: IconButton(
                onPressed: () => togglePasswordVisibility("new"),
                icon: IconVisibility(visibility: _passwordVisibility["new"]!),
              ),
            ),
            maxLength: 50,
            obscureText: _passwordVisibility["new"]!,
            validator: (value) => PwdValidationHelper.validatePassword(
              password: value!,
              comparisonDifferent: oldPasswordController.text,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: retypePasswordController,
            decoration: InputDecoration(
              labelText: 'Retype password',
              suffixIcon: IconButton(
                onPressed: () => togglePasswordVisibility("retype"),
                icon:
                    IconVisibility(visibility: _passwordVisibility["retype"]!),
              ),
            ),
            maxLength: 50,
            obscureText: _passwordVisibility["retype"]!,
            validator: (value) => PwdValidationHelper.validatePassword(
                password: value!, comparisonSame: newPasswordController.text),
          ),
          const SizedBox(height: 16),
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
                  if (_formKey.currentState!.validate()) {
                    profileViewModel.updatePassword(
                      oldPasswordController.text,
                      newPasswordController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('${widget.action} password'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
