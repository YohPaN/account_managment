import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final item;
  const ListItem({super.key, required this.item});

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
          child: Text(item.valuation + "€"),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.mode))
      ],
    );
  }
}
