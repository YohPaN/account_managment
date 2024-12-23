import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/has_permissions.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDrawer extends StatefulWidget {
  final String action;
  final Item? item;

  @override
  const ItemDrawer({super.key, required this.action, this.item});

  @override
  _ItemDrawerState createState() => _ItemDrawerState();
}

class _ItemDrawerState extends State<ItemDrawer> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController valuationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<bool> _selectButton = [true, false];
  String _username = "";

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

    if (widget.action == "update") {
      if (widget.item!.valuation > 0) {
        _selectButton[0] = false;
        _selectButton[1] = true;
        _buttonStyle = buttonStyleChoices[1];
      }
      if (widget.item != null) {
        titleController.text = widget.item!.title;
        descriptionController.text = widget.item!.description;
        valuationController.text = widget.item!.valuation.abs().toString();
        _username = widget.item!.username ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AccountViewModel accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);

    switchButton(index) {
      setState(() {
        for (int i = 0; i < _selectButton.length; i++) {
          _selectButton[i] = i == index;
        }

        _buttonStyle = buttonStyleChoices[index];
      });
    }

    final List<DropdownMenuEntry<String>> menuEntries = [
      DropdownMenuEntry<String>(
        value: accountViewModel.account!.user,
        label: "Me",
      ),
    ];

    if (widget.action == "update" ||
        HasPermissions.hasSpecificPerm(
            permission: "link_user_item",
            permissions: accountViewModel.account!.permissions)) {
      menuEntries.addAll(
        accountViewModel.account!.contributor.map(
          (contributor) => DropdownMenuEntry<String>(
            value: contributor.username,
            label: contributor.username,
          ),
        ),
      );
    }

    if (widget.action == "update" ||
        HasPermissions.hasSpecificPerm(
          permission: "add_item_without_user",
          permissions: accountViewModel.account!.permissions,
        )) {
      menuEntries.add(
        const DropdownMenuEntry<String>(
          value: "",
          label: "",
        ),
      );
    } else {
      _username = accountViewModel.account!.user;
    }

    createOrUpdate() async {
      final valuation = _selectButton[0]
          ? "-${valuationController.text}"
          : valuationController.text;

      if (widget.action == "create") {
        return await accountViewModel.createItem(
          title: titleController.text,
          description: descriptionController.text,
          valuation: valuation,
          username: _username != "" ? _username : null,
        );
      } else {
        return await accountViewModel.updateItem(
          title: titleController.text,
          description: descriptionController.text,
          valuation: valuation,
          username: _username != "" ? _username : null,
          itemId: widget.item!.id,
        );
      }
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
                validator: (value) => ValidationHelper.validateInput(value, [
                  "notEmpty",
                  "notNull",
                  "twoDigitMax",
                  "validPositifDouble"
                ]),
              ),
              const SizedBox(height: 16),
              DropdownMenu(
                initialSelection: _username,
                onSelected: (value) => setState(() {
                  _username = value!;
                }),
                dropdownMenuEntries: menuEntries,
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
                  if (widget.action == "update" &&
                      HasPermissions.hasPermissions(
                          ressource: "item",
                          action: "delete",
                          permissions: accountViewModel.account!.permissions))
                    ElevatedButton(
                      onPressed: () async {
                        RepoResponse repoResponse =
                            await accountViewModel.deleteItem(widget.item!.id);
                        Provider.of<InternalNotification>(context,
                                listen: false)
                            .showMessage(
                                repoResponse.message, repoResponse.success);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete Item'),
                    ),
                  if (HasPermissions.hasPermissions(
                      ressource: "item",
                      action: widget.action,
                      permissions: accountViewModel.account!.permissions))
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          RepoResponse repoResponse = await createOrUpdate();

                          Provider.of<InternalNotification>(context,
                                  listen: false)
                              .showMessage(
                                  repoResponse.message, repoResponse.success);
                          Navigator.pop(context);
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
