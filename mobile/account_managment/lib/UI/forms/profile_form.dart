import 'package:account_managment/helpers/internal_notification_helper.dart';
import 'package:account_managment/helpers/navigation_index_helper.dart';
import 'package:account_managment/UI/components/password/password_drawer.dart';
import 'package:account_managment/UI/components/password/password_field.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/show_modal_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/profile.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/models/user.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final AppLocalizations locale = AppLocalizations.of(context)!;

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
              textCapitalization: TextCapitalization.sentences,
              initialValue: profile?.firstName,
              keyboardType: TextInputType.name,
              maxLength: 15,
              decoration:
                  InputDecoration(labelText: locale.first_name.capitalize()),
              onSaved: (value) {
                formData['firstName'] = value ?? '';
              },
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull", "validTextOnly"]),
            ),
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              initialValue: profile?.lastName,
              keyboardType: TextInputType.name,
              maxLength: 15,
              decoration:
                  InputDecoration(labelText: locale.last_name.capitalize()),
              onSaved: (value) {
                formData['lastName'] = value ?? '';
              },
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull", "validTextOnly"]),
            ),
            TextFormField(
              initialValue: user?.username,
              maxLength: 15,
              decoration:
                  InputDecoration(labelText: locale.username.capitalize()),
              onSaved: (value) {
                formData['username'] = value ?? '';
              },
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
            ),
            TextFormField(
                initialValue: user?.email,
                keyboardType: TextInputType.emailAddress,
                maxLength: 50,
                decoration:
                    InputDecoration(labelText: locale.email.capitalize()),
                onSaved: (value) {
                  formData['email'] = value ?? '';
                },
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validEmail"])),
            TextFormField(
              initialValue: profile?.salary.toString(),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              maxLength: 15,
              decoration:
                  InputDecoration(labelText: locale.salary.capitalize()),
              onSaved: (value) {
                formData['salary'] = value ?? '';
              },
              validator: (value) => ValidationHelper.validateInput(
                  value, ["validPositifDouble", "twoDigitMax"]),
            ),
            if (widget.action == "create")
              Column(children: [
                PasswordField(
                  label: locale.new_password.capitalize(),
                  index: "newPassword",
                  formData: formData,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  label: locale.retype_password.capitalize(),
                  index: "retypePassword",
                  formData: formData,
                  comparisonSame: "newPassword",
                ),
              ]),
            if (widget.action == "update")
              ElevatedButton(
                onPressed: () {
                  showModalHelper<PasswordDrawerState>(
                    context: context,
                    childBuilder: (context) {
                      return PasswordDrawerState(
                        action: widget.action,
                      );
                    },
                  );
                },
                child: Text(
                    "${locale.action(widget.action).capitalize()} ${locale.the("the")} ${locale.password}"),
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
                "${locale.action(widget.action).capitalize()} ${locale.the("the")} ${locale.profile}",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
