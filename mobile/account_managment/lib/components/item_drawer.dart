import 'package:account_managment/models/item.dart';
import 'package:account_managment/viewModels/item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDrawer extends StatelessWidget {
  final Function closeCallback;
  final String action;
  final Item? item;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController valuationController = TextEditingController();

  ItemDrawer(
      {super.key,
      required this.closeCallback,
      required this.action,
      this.item});

  @override
  Widget build(BuildContext context) {
    final itemViewModel = Provider.of<ItemViewModel>(context);

    createOrUpdate() async {
      if (action == "create") {
        await itemViewModel.create(
          titleController.text,
          descriptionController.text,
          valuationController.text,
        );
      } else if (action == "update") {
        await itemViewModel.update(
          item!.id,
          titleController.text,
          descriptionController.text,
          valuationController.text,
        );
      }
    }

    if (action == "update" && item != null) {
      titleController.text = item!.title;
      descriptionController.text = item!.description;
      valuationController.text = item!.valuation;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: valuationController,
            decoration: const InputDecoration(labelText: 'Valuation'),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(
              onPressed: () async {
                await createOrUpdate();
                closeCallback();
              },
              child: Text('$action Item'),
            ),
            ElevatedButton(
              onPressed: () async {
                await itemViewModel.delete(item!.id);
                closeCallback();
              },
              child: const Text('Delete Item'),
            ),
          ]),
        ],
      ),
    );
  }
}
