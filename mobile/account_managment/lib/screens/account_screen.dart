import 'package:account_managment/components/item_drawer.dart';
import 'package:account_managment/components/list_item.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/has_permissions.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);

    showModal(String action, [Item? item]) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (BuildContext drawerContext) {
          return InheritedProvider<AccountViewModel>(
            update: (context, value) {
              return accountViewModel;
            },
            child: ItemDrawer(
              item: item,
              action: action,
            ),
          );
        },
      );
    }

    Future<RepoResponse?> getAccount() async {
      var accountID =
          accountViewModel.accountIdToRetrieve ?? accountViewModel.account?.id;
      return accountViewModel.getAccount(accountID);
    }

    return Consumer<AccountViewModel>(
      builder: (context, accountViewModel, child) {
        return FutureBuilder(
          future: getAccount(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.success) {
                return Scaffold(
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: Text(
                                  accountViewModel.account!.name.capitalize(),
                                  style: const TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold),
                                )),
                                Text(
                                  "${accountViewModel.account!.total != null ? accountViewModel.account!.total!.toStringAsFixed(2) : "0.00"}€",
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      color: accountViewModel.account!.total !=
                                                  null &&
                                              accountViewModel.account!.total! <
                                                  0
                                          ? Colors.red[600]
                                          : Colors.green[500]),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                    child: Text(
                                  "Your contribution",
                                  style: TextStyle(),
                                )),
                                Text(
                                  accountViewModel.account!.ownContribution !=
                                          null
                                      ? accountViewModel
                                          .account!.ownContribution!
                                          .toStringAsFixed(2)
                                      : "0.00",
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                    child: Text(
                                  "Need to add",
                                  style: TextStyle(),
                                )),
                                Text(
                                  accountViewModel.account!.needToAdd != null
                                      ? accountViewModel.account!.needToAdd!
                                          .toStringAsFixed(2)
                                      : "0.00",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color:
                                          accountViewModel.account!.needToAdd !=
                                                      null &&
                                                  accountViewModel
                                                          .account!.needToAdd! <
                                                      0
                                              ? Colors.red[600]
                                              : Colors.green[500]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async =>
                              {await accountViewModel.refreshAccount()},
                          child: ListView.builder(
                            itemCount:
                                accountViewModel.account!.items.length ?? 0,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 8, bottom: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 4.0,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: ListItem(
                                      item: accountViewModel
                                          .account!.items[index],
                                      callbackFunc: showModal,
                                      canManage: HasPermissions.hasPermissions(
                                          ressource: "item",
                                          action: "updateOrDelete",
                                          permissions: accountViewModel
                                              .account!.permissions,
                                          strict: false),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: Visibility(
                    visible: HasPermissions.hasPermissions(
                        ressource: "item",
                        action: "create",
                        permissions: accountViewModel.account!.permissions),
                    child: FloatingActionButton(
                      onPressed: () => showModal("create"),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.add),
                    ),
                  ),
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
        );
      },
    );
  }
}
