import 'package:account_managment/components/item_drawer.dart';
import 'package:account_managment/models/item.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Item item;

  const ListItem({
    super.key,
    required this.item,
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
                  action: "update",
                  item: item,
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
