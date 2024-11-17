import 'package:account_managment/components/account_drawer.dart';
import 'package:account_managment/models/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AccountListItem extends StatelessWidget {
  final Account account;
  final bool canManage;
  final Function navigateToAccount;

  const AccountListItem(
      {super.key,
      required this.account,
      required this.canManage,
      required this.navigateToAccount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.only(right: 0, left: 16.0),
          ),
        ),
        onPressed: () async => {
          navigateToAccount(account.id),
          Navigator.pop(context, '/accounts')
        },
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text("${(account.total ?? 0).toStringAsFixed(2)}€"),
            ),
            if (canManage)
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return AccountDrawer(
                        closeCallback: () {
                          Navigator.pop(context);
                        },
                        action: "update",
                        account: account,
                      );
                    },
                  );
                },
                icon: const Icon(Icons.mode),
              ),
          ],
        ),
      ),
    );
  }
}
