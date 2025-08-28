import 'package:account_managment/UI/components/accounts/account_list_item.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) {
        return Scaffold(
          body: FutureBuilder(
            future: accountViewModel.listAccount(
                user: profileViewModel.user!.username),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.success) {
                  return RefreshIndicator(
                    onRefresh: () async => {
                      await accountViewModel.listAccount(
                          user: profileViewModel.user!.username)
                    },
                    child: Column(children: [
                      Text(
                          "${locale.possessive("yours").capitalize()} ${locale.account("many")}"),
                      Expanded(
                        child: ListView.builder(
                          itemCount: accountViewModel.accounts.length,
                          itemBuilder: (context, index) {
                            return AccountListItem(
                              account: accountViewModel.accounts[index],
                              canManage: true,
                            );
                          },
                        ),
                      ),
                      const Divider(color: Colors.black),
                      Text(locale.contributor_account("many").capitalize()),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              accountViewModel.contributorAccounts?.length ?? 0,
                          itemBuilder: (context, index) {
                            return AccountListItem(
                              account:
                                  accountViewModel.contributorAccounts![index],
                              canManage: profileViewModel.user!.hasPermission(
                                account: accountViewModel
                                    .contributorAccounts![index],
                                permissionsNeeded: [
                                  "change_account",
                                  "delete_account"
                                ],
                                permissions: accountViewModel
                                    .contributorAccounts![index].permissions,
                                strict: false,
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
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
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                "account_managment",
                arguments: "create",
              );
            },
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
