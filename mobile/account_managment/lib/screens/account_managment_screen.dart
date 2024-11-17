import 'package:account_managment/components/account_drawer.dart';
import 'package:account_managment/components/account_list_item.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountManagmentScreen extends StatelessWidget {
  const AccountManagmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountViewModel = Provider.of<AccountViewModel>(context);

    if (accountViewModel.accounts == null) {
      accountViewModel.listAccount();
    }

    navigateToAccount(accountId) async {
      await accountViewModel.getAccount(accountId);
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
                        account: accountViewModel.account!,
                        canManage: true,
                        navigateToAccount: navigateToAccount,
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
                        canManage: false,
                        navigateToAccount: navigateToAccount,
                      );
                    },
                  ),
                ),
              ]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            isScrollControlled: true,
            builder: (BuildContext context) {
              return AccountDrawer(
                closeCallback: () {
                  Navigator.pop(context);
                },
                action: "create",
              );
            },
          );
        },
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.add),
      ),
    );
  }
}
