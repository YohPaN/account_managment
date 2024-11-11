import 'package:account_managment/components/create_item.dart';
import 'package:account_managment/models/item.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Item item;
  final Function(int) callbackFn;
  int accountId;
  ListItem(
      {super.key,
      required this.item,
      required this.callbackFn,
      required this.accountId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(item.title), Text(item.description)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text("${item.valuation}€"),
        ),
        IconButton(
            onPressed: () => showBottomDrawer(
                context: context,
                accountId: accountId,
                closeCallback: (int accountId) => callbackFn(accountId),
                createOrUpdate: "update",
                item: item),
            icon: const Icon(Icons.mode))
      ],
    );
  }
}
