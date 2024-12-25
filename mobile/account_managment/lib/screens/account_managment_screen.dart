import 'package:account_managment/components/account_drawer.dart';
import 'package:account_managment/components/account_list_item.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountManagmentScreen extends StatelessWidget {
  const AccountManagmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountViewModel = Provider.of<AccountViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    showModal(String action, [Account? account]) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (BuildContext drawerContext) {
          return MultiProvider(
            providers: [
              InheritedProvider<AccountViewModel>(
                update: (context, value) {
                  return accountViewModel;
                },
              ),
              InheritedProvider<ProfileViewModel>(
                update: (context, value) {
                  return profileViewModel;
                },
              ),
            ],
            child: AccountDrawer(
              account: account,
              action: action,
            ),
          );
        },
      );
    }

    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) {
        return Scaffold(
          body: FutureBuilder(
            future: accountViewModel.listAccount(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.success) {
                  return RefreshIndicator(
                    onRefresh: () async =>
                        {await accountViewModel.listAccount()},
                    child: Column(children: [
                      const Text("Your accounts"),
                      Expanded(
                        child: ListView.builder(
                          itemCount: accountViewModel.accounts?.length ?? 0,
                          itemBuilder: (context, index) {
                            return AccountListItem(
                              account: accountViewModel.accounts![index],
                              callbackFunc: showModal,
                              canManage: true,
                            );
                          },
                        ),
                      ),
                      const Divider(color: Colors.black),
                      const Text("Associate accounts"),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              accountViewModel.contributorAccounts?.length ?? 0,
                          itemBuilder: (context, index) {
                            return AccountListItem(
                              account:
                                  accountViewModel.contributorAccounts![index],
                              callbackFunc: showModal,
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
              showModal("create");
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
