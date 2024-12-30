import 'package:account_managment/models/item.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Item item;
  final int accountId;
  final Function(String, Item) callbackFunc;
  bool canManage = false;

  ListItem({
    super.key,
    required this.item,
    required this.accountId,
    required this.callbackFunc,
    required this.canManage,
  });

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
                Text(item.title),
                Text(item.description ?? ""),
              ],
            ),
          ),
        ),
        if (item.transfertItem)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.input),
          ),
        if (item.toAccount!["id"] != null &&
            item.toAccount!["id"] != accountId.toString())
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.output),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text("${item.valuation.toStringAsFixed(2)}€"),
        ),
        if (canManage && !item.transfertItem)
          IconButton(
            onPressed: () {
              callbackFunc("update", item);
            },
            icon: const Icon(Icons.mode),
          ),
      ],
    );
  }
}
