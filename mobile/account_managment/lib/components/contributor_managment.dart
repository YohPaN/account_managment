import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ContributorManagment extends StatelessWidget {
  const ContributorManagment({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;
    final accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);
    final TextEditingController userToAddController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: userToAddController,
        decoration: InputDecoration(
          labelText: locale.add_users.capitalize(),
          suffixIcon: IconButton(
            onPressed: () async {
              RepoResponse repoResponse = await accountViewModel.addContributor(
                  userUsername: userToAddController.text);
              Provider.of<InternalNotification>(context, listen: false)
                  .showMessage(repoResponse.message, repoResponse.success);
              userToAddController.clear();
            },
            icon: const Icon(Icons.add),
          ),
        ),
        maxLength: 15,
      ),
    );
  }
}
