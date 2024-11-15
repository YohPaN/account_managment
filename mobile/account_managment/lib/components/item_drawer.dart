import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/viewModels/item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDrawer extends StatefulWidget {
  final Function closeCallback;
  final String action;
  final Item? item;

  @override
  const ItemDrawer(
      {super.key,
      required this.closeCallback,
      required this.action,
      this.item});

  @override
  _ItemDrawerState createState() => _ItemDrawerState();
}

class _ItemDrawerState extends State<ItemDrawer> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController valuationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final itemViewModel = Provider.of<ItemViewModel>(context);

    createOrUpdate() async {
      if (widget.action == "create") {
        await itemViewModel.create(
          titleController.text,
          descriptionController.text,
          valuationController.text,
        );
      } else if (widget.action == "update") {
        await itemViewModel.update(
          widget.item!.id,
          titleController.text,
          descriptionController.text,
          valuationController.text,
        );
      }
    }

    if (widget.action == "update" && widget.item != null) {
      titleController.text = widget.item!.title;
      descriptionController.text = widget.item!.description;
      valuationController.text = widget.item!.valuation;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 15,
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLength: 50,
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull"]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: valuationController,
              decoration: const InputDecoration(labelText: 'Valuation'),
              maxLength: 15,
              validator: (value) => ValidationHelper.validateInput(
                  value, ["notEmpty", "notNull", "validDouble", "twoDigitMax"]),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await createOrUpdate();
                    widget.closeCallback();
                  }
                },
                child: Text('${widget.action} Item'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await itemViewModel.delete(widget.item!.id);
                  widget.closeCallback();
                },
                child: const Text('Delete Item'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
