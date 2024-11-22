import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/components/icon_visibility.dart';
import 'package:account_managment/components/password_drawer.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/pwd_validation_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/user.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileForm extends StatefulWidget {
  final String action;
  const ProfileForm({super.key, required this.action});

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController retypePasswordController =
      TextEditingController();

  final Map<String, bool> _passwordVisibility = {
    "new": true,
    "retype": true,
  };

  void togglePasswordVisibility(String key) {
    setState(() {
      _passwordVisibility[key] = !_passwordVisibility[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    User? user = profileViewModel.user;
    Profile? profile = profileViewModel.profile;

    if (widget.action == "update") {
      if ((profile == null || user == null)) {
        profileViewModel.getProfile();
        user = profileViewModel.user;
        profile = profileViewModel.profile;
      }

      if (profile != null && user != null) {
        usernameController.text = user.username;
        firstNameController.text = profile.firstName;
        lastNameController.text = profile.lastName;
        emailController.text = user.email;
        salaryController.text = profile.salary!.toStringAsFixed(2);
      }
    }

    createOrUpdate() async {
      late Function(String, String, String, String, String, String)
          actionFunction;

      if (widget.action == "create") {
        actionFunction = profileViewModel.createProfile;
      } else if (widget.action == "update") {
        actionFunction = profileViewModel.updateProfile;
      }

      await actionFunction(
        usernameController.text,
        firstNameController.text,
        lastNameController.text,
        emailController.text,
        salaryController.text,
        newPasswordController.text,
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(children: [
        TextFormField(
          controller: firstNameController,
          maxLength: 15,
          decoration: const InputDecoration(labelText: 'First name'),
          validator: (value) => ValidationHelper.validateInput(
              value, ["notEmpty", "notNull", "validTextOnly"]),
        ),
        TextFormField(
          controller: lastNameController,
          maxLength: 15,
          decoration: const InputDecoration(labelText: 'Last name'),
          validator: (value) => ValidationHelper.validateInput(
              value, ["notEmpty", "notNull", "validTextOnly"]),
        ),
        TextFormField(
          controller: usernameController,
          maxLength: 15,
          decoration: const InputDecoration(labelText: 'Username'),
          validator: (value) => ValidationHelper.validateInput(
              value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
        ),
        TextFormField(
          controller: emailController,
          maxLength: 50,
          decoration: const InputDecoration(labelText: 'Email'),
          // validator: (value) => ValidationHelper.validateInput(
          //     value, ["notEmpty", "notNull", "validEmail"])
        ),
        TextFormField(
          controller: salaryController,
          maxLength: 15,
          decoration: const InputDecoration(labelText: 'Salary'),
          validator: (value) => ValidationHelper.validateInput(
              value, ["validPositifDouble", "twoDigitMax"]),
        ),
        if (widget.action == "create")
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
            // validator: (value) =>
            //     PwdValidationHelper.validatePassword(password: value!),
          ),
        const SizedBox(height: 16),
        if (widget.action == "create")
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
            // validator: (value) => PwdValidationHelper.validatePassword(
            //     password: value!, comparisonSame: newPasswordController.text),
          ),
        const SizedBox(height: 16),
        if (widget.action == "update")
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return PasswordDrawerState(
                    action: widget.action,
                  );
                },
              );
            },
            child: const Text("Update my password"),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await createOrUpdate();
              if (profileViewModel.profile != null) {
                if (!context.mounted) return;
                Navigator.pop(context);
              } else {
                if (!context.mounted) return;
                context
                    .read<InternalNotification>()
                    .showError("Wrong username or password");
              }
            }
          },
          child: Text("${widget.action} my account".capitalize()),
        ),
      ])),
    );
  }
}
