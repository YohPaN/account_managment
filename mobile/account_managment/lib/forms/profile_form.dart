import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/components/icon_visibility.dart';
import 'package:account_managment/components/password_drawer.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/models/user.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//TODO: update password correctly
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
    final Map<String, String> _formData = {};
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
        _formData["username"]!,
        _formData["firstName"]!,
        _formData["lastName"]!,
        _formData["email"]!,
        _formData["salary"] ?? "",
        _formData["newPassword"] ?? "",
      );
    }

    Future<void> saveForm() async {
      _formKey.currentState!.save();
    }

    return FutureBuilder(
      future: profileViewModel.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //TODO: pas fan car ca leve une erreur
          if (snapshot.data!.success || widget.action == "create") {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: profileViewModel.profile?.firstName,
                      maxLength: 15,
                      decoration:
                          const InputDecoration(labelText: 'First name'),
                      onSaved: (value) {
                        _formData['firstName'] = value ?? '';
                      },
                      validator: (value) => ValidationHelper.validateInput(
                          value, ["notEmpty", "notNull", "validTextOnly"]),
                    ),
                    TextFormField(
                      initialValue: profileViewModel.profile?.lastName,
                      maxLength: 15,
                      decoration: const InputDecoration(labelText: 'Last name'),
                      onSaved: (value) {
                        _formData['lastName'] = value ?? '';
                      },
                      validator: (value) => ValidationHelper.validateInput(
                          value, ["notEmpty", "notNull", "validTextOnly"]),
                    ),
                    TextFormField(
                      initialValue: profileViewModel.user?.username,
                      maxLength: 15,
                      decoration: const InputDecoration(labelText: 'Username'),
                      onSaved: (value) {
                        _formData['username'] = value ?? '';
                      },
                      validator: (value) => ValidationHelper.validateInput(
                          value,
                          ["notEmpty", "notNull", "validTextOrDigitOnly"]),
                    ),
                    TextFormField(
                      initialValue: profileViewModel.user?.email,
                      maxLength: 50,
                      decoration: const InputDecoration(labelText: 'Email'),
                      onSaved: (value) {
                        _formData['email'] = value ?? '';
                      },
                      // validator: (value) => ValidationHelper.validateInput(
                      //     value, ["notEmpty", "notNull", "validEmail"])
                    ),
                    TextFormField(
                      initialValue: profileViewModel.profile?.salary.toString(),
                      maxLength: 15,
                      decoration: const InputDecoration(labelText: 'Salary'),
                      onSaved: (value) {
                        print(value);
                        _formData['salary'] = value ?? '';
                      },
                      validator: (value) => ValidationHelper.validateInput(
                          value, ["validPositifDouble", "twoDigitMax"]),
                    ),
                    if (widget.action == "create")
                      TextFormField(
                        // controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New password',
                          suffixIcon: IconButton(
                            onPressed: () => togglePasswordVisibility("new"),
                            icon: IconVisibility(
                                visibility: _passwordVisibility["new"]!),
                          ),
                        ),
                        maxLength: 50,
                        obscureText: _passwordVisibility["new"]!,
                        onSaved: (value) {
                          _formData['newPassword'] = value ?? '';
                        },
                        // validator: (value) =>
                        //     PwdValidationHelper.validatePassword(password: value!),
                      ),
                    const SizedBox(height: 16),
                    if (widget.action == "create")
                      TextFormField(
                        // controller: retypePasswordController,
                        decoration: InputDecoration(
                          labelText: 'Retype password',
                          suffixIcon: IconButton(
                            onPressed: () => togglePasswordVisibility("retype"),
                            icon: IconVisibility(
                                visibility: _passwordVisibility["retype"]!),
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
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
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
                          await saveForm();
                          final RepoResponse repoResponse =
                              await createOrUpdate();
                          Provider.of<InternalNotification>(context,
                                  listen: false)
                              .showMessage(
                                  repoResponse.message, repoResponse.success);
                          Navigator.pop(context);
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
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Text(
                  snapshot.data!.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ),
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
