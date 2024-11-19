import 'package:account_managment/helpers/capitalize_helper.dart';
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
  final List<bool> _selectButton = [true, false];
  final List<Map<String, Color?>> buttonStyleChoices = [
    {
      "selectedColor": Colors.red[700],
      "fillColor": Colors.red[200],
      "color": Colors.red[400]
    },
    {
      "selectedColor": Colors.green[700],
      "fillColor": Colors.green[200],
      "color": Colors.green[400]
    }
  ];

  late Map<String, Color?> _buttonStyle;

  @override
  void initState() {
    super.initState();
    _buttonStyle = buttonStyleChoices[0];

    if (widget.action == "update" && widget.item!.valuation > 0) {
      _selectButton[0] = false;
      _selectButton[1] = true;
      _buttonStyle = buttonStyleChoices[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemViewModel = Provider.of<ItemViewModel>(context);

    switchButton(index) {
      setState(() {
        for (int i = 0; i < _selectButton.length; i++) {
          _selectButton[i] = i == index;
        }

        _buttonStyle = buttonStyleChoices[index];
      });
    }

    createOrUpdate() async {
      final valuation = _selectButton[0]
          ? "-${valuationController.text}"
          : valuationController.text;

      if (widget.action == "create") {
        await itemViewModel.createItem(
          titleController.text,
          descriptionController.text,
          valuation,
        );
      } else if (widget.action == "update") {
        await itemViewModel.updateItem(
          widget.item!.id,
          titleController.text,
          descriptionController.text,
          valuation,
        );
      }
    }

    if (widget.action == "update" && widget.item != null) {
      titleController.text = widget.item!.title;
      descriptionController.text = widget.item!.description;
      valuationController.text = widget.item!.valuation.abs().toString();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 4.0,
      ),
      child: SingleChildScrollView(
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
                validator: (value) => ValidationHelper.validateInput(value,
                    ["notEmpty", "notNull", "twoDigitMax", "validPositifDouble"]),
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                onPressed: (int index) => switchButton(index),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: _buttonStyle["selectedColor"],
                selectedColor: Colors.white,
                fillColor: _buttonStyle["fillColor"],
                color: _buttonStyle["color"],
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: _selectButton,
                children: const [Text("Expense"), Text("Income")],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.action == "update")
                    ElevatedButton(
                      onPressed: () async {
                        await itemViewModel.deleteItem(widget.item!.id);
                        widget.closeCallback();
                      },
                      child: const Text('Delete Item'),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await createOrUpdate();
                        widget.closeCallback();
                      }
                    },
                    child: Text('${widget.action} Item'.capitalize()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
