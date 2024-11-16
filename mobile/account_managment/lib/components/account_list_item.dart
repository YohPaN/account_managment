import 'package:account_managment/components/account_drawer.dart';
import 'package:account_managment/models/account.dart';
import 'package:flutter/material.dart';

class AccountListItem extends StatelessWidget {
  final Account account;
  const AccountListItem({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        IconButton(
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
                  action: "update",
                  account: account,
                );
              },
            );
          },
          icon: const Icon(Icons.mode),
        ),
      ],
    );
  }
}
