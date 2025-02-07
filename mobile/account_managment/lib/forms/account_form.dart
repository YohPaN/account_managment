import 'dart:async';

import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountForm extends StatelessWidget {
  final String action;
  final int? accountId;

  const AccountForm({
    super.key,
    required this.action,
    this.accountId,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final AppLocalizations locale = AppLocalizations.of(context)!;

    final accountViewModel = Provider.of<AccountViewModel>(context);
    final TextEditingController nameController = TextEditingController(
        text: accountViewModel.account?.name != null && action == 'update'
            ? accountViewModel.account?.name
            : '');

    Future<RepoResponse> submit(String accountName) async {
      if (action == "create") {
        return await accountViewModel.createAccount(accountName: accountName);
      } else {
        return await accountViewModel.updateAccount(
          accountName: accountName,
        );
      }
    }

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<AccountViewModel>(
              builder: (context, accountViewModel, child) => Expanded(
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: nameController,
                  decoration:
                      InputDecoration(labelText: locale.title.capitalize()),
                  maxLength: 30,
                  validator: (value) => ValidationHelper.validateInput(
                      value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  RepoResponse repoResponse = await submit(nameController.text);
                  Provider.of<InternalNotification>(context, listen: false)
                      .showMessage(repoResponse.message, repoResponse.success);
                }
              },
              child: Text(locale.action(action).capitalize()),
            ),
          ],
        ),
      ),
    );
  }
}
