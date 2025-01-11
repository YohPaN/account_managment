import 'package:account_managment/common/profile_form_future_builder.dart';
import 'package:account_managment/forms/profile_form.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  String action;

  ProfileScreen({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!
              .action_account(action, "your")
              .capitalize())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: action == "create"
            ? ProfileForm(action: action)
            : ProfileFormFutureBuilder(
                child: ProfileForm(action: action),
              ),
      ),
    );
  }
}
