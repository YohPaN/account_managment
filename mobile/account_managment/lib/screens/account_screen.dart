import 'package:account_managment/components/item_drawer.dart';
import 'package:account_managment/components/list_item.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountViewModel = Provider.of<AccountViewModel>(context);

    if (accountViewModel.account == null) {
      accountViewModel.getAccount();
    }

    return Scaffold(
      body: accountViewModel.account == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        accountViewModel.account!.name.capitalize(),
                        style: const TextStyle(
                            fontSize: 34.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${accountViewModel.account!.total != null ? accountViewModel.account!.total!.toStringAsFixed(2) : "0.00"}€",
                        style: TextStyle(
                            fontSize: 24.0,
                            color: accountViewModel.account!.total != null &&
                                    accountViewModel.account!.total! < 0
                                ? Colors.red[600]
                                : Colors.green[500]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        {await accountViewModel.refreshAccount()},
                    child: ListView.builder(
                      itemCount: accountViewModel.account!.items.length ?? 0,
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
                                  item: accountViewModel.account!.items[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
              return ItemDrawer(
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
