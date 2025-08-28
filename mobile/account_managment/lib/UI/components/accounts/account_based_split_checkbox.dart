import 'package:account_managment/helpers/internal_notification_helper.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class AccountBasedSplitCheckboxState extends StatelessWidget {
  const AccountBasedSplitCheckboxState({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) => CheckboxListTile(
        title: Text(locale.salary_based_split.capitalize()),
        value: accountViewModel.account!.salaryBasedSplit,
        onChanged: (bool? value) async {
          final RepoResponse repoResponse =
              await accountViewModel.setSalaryBasedSplit(
            isSplit: value!,
          );
          Provider.of<InternalNotification>(context, listen: false)
              .showMessage(repoResponse.message, repoResponse.success);
        },
      ),
    );
  }
}
