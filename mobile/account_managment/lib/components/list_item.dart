import 'package:account_managment/models/item.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Item item;
  final Function(String, Item) callbackFunc;

  const ListItem({
    super.key,
    required this.item,
    required this.callbackFunc,
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
                Text(item.description),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text("${item.valuation.toStringAsFixed(2)}€"),
        ),
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
