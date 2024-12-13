import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/common/navigation_index.dart';
import 'package:account_managment/components/password_drawer.dart';
import 'package:account_managment/components/password_field.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/repo_reponse.dart';
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
    final Map<String, String> formData = {};
    User? user = profileViewModel.user;
    Profile? profile = profileViewModel.profile;

    createOrUpdate() async {
      late Function(String, String, String, String, String, String)
          actionFunction;

      if (widget.action == "create") {
        actionFunction = profileViewModel.createProfile;
      } else if (widget.action == "update") {
        actionFunction = profileViewModel.updateProfile;
      }

      return actionFunction(
        formData["username"]!,
        formData["firstName"]!,
        formData["lastName"]!,
        formData["email"]!,
        formData["salary"] ?? "",
        formData["newPassword"] ?? "",
      );
    }

    Future<void> saveForm() async {
      _formKey.currentState!.save();
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              initialValue: profileViewModel.profile?.firstName,
              maxLength: 15,
              decoration: const InputDecoration(labelText: 'First name'),
              onSaved: (value) {
                formData['firstName'] = value ?? '';
              },
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull", "validTextOnly"]),
            ),
            TextFormField(
              initialValue: profileViewModel.profile?.lastName,
              maxLength: 15,
              decoration: const InputDecoration(labelText: 'Last name'),
              onSaved: (value) {
                formData['lastName'] = value ?? '';
              },
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull", "validTextOnly"]),
            ),
            TextFormField(
              initialValue: profileViewModel.user?.username,
              maxLength: 15,
              decoration: const InputDecoration(labelText: 'Username'),
              onSaved: (value) {
                formData['username'] = value ?? '';
              },
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
            ),
            TextFormField(
              initialValue: profileViewModel.user?.email,
              maxLength: 50,
              decoration: const InputDecoration(labelText: 'Email'),
              onSaved: (value) {
                formData['email'] = value ?? '';
              },
              // validator: (value) => ValidationHelper.validateInput(
              //     value, ["notEmpty", "notNull", "validEmail"])
            ),
            TextFormField(
              initialValue: profileViewModel.profile?.salary.toString(),
              maxLength: 15,
              decoration: const InputDecoration(labelText: 'Salary'),
              onSaved: (value) {
                formData['salary'] = value ?? '';
              },
              validator: (value) => ValidationHelper.validateInput(
                  value, ["validPositifDouble", "twoDigitMax"]),
            ),
            if (widget.action == "create")
              Column(children: [
                PasswordField(
                  label: "New password",
                  index: "newPassword",
                  formData: formData,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  label: "Retype password",
                  index: "retypePassword",
                  formData: formData,
                  comparisonSame: "newPassword",
                ),
              ]),
            if (widget.action == "update")
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
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
                await saveForm();
                if (_formKey.currentState!.validate()) {
                  final RepoResponse repoResponse = await createOrUpdate();
                  Provider.of<InternalNotification>(context, listen: false)
                      .showMessage(repoResponse.message, repoResponse.success);
                  if (widget.action == "create") {
                    Navigator.pop(context);
                  } else {
                    Provider.of<NavigationIndex>(context, listen: false)
                        .changeIndex(0);
                  }
                }
              },
              child: Text(
                "${widget.action} my account".capitalize(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
