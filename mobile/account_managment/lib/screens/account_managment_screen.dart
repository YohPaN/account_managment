import 'package:account_managment/components/account_based_split_checkbox.dart';
import 'package:account_managment/forms/account_form.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class AccountManagmentScreen extends StatelessWidget {
  const AccountManagmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;
    final action = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.account_managment.capitalize()),
      ),
      body: Column(
        children: [
          AccountForm(action: action),
          if (action == "update") const AccountBasedSplitCheckboxState()
        ],
      ),
    );
  }
}
