import 'package:account_managment/components/item_drawer.dart';
import 'package:account_managment/models/item.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Item item;

  ListItem({
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
          child: Text("${item.valuation}€"),
        ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              isScrollControlled:
                  true, // Makes the bottom sheet full-screen if needed
              builder: (BuildContext context) {
                return ItemDrawer(
                  closeCallback: () {
                    Navigator.pop(context); // Close the bottom sheet
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
