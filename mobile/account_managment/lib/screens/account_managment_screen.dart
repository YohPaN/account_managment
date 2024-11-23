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

    if (accountViewModel.accounts == null) {
      accountViewModel.listAccount();
    }

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

    return Scaffold(
      body: accountViewModel.account == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => {await accountViewModel.listAccount()},
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
                        account: accountViewModel.contributorAccounts![index],
                        callbackFunc: showModal,
                        canManage: false,
                      );
                    },
                  ),
                ),
              ]),
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
  }
}
