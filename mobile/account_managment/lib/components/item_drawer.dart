import 'package:account_managment/common/internal_notification.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemDrawer extends StatefulWidget {
  final String action;
  final Item? item;

  @override
  const ItemDrawer({
    super.key,
    required this.action,
    this.item,
  });

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
  String _toAccount = "";
  String _category = "";

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
        descriptionController.text = widget.item!.description ?? "";
        valuationController.text = widget.item!.valuation.abs().toString();
        _username = widget.item!.username ?? "";
        _toAccount = widget.item!.toAccount?["id"] ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AccountViewModel accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);
    final ProfileViewModel profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    final CategoryViewModel categoryViewModel =
        Provider.of<CategoryViewModel>(context, listen: false);
    final AppLocalizations locale = AppLocalizations.of(context)!;

    switchButton(index) {
      setState(() {
        for (int i = 0; i < _selectButton.length; i++) {
          _selectButton[i] = i == index;
        }

        _buttonStyle = buttonStyleChoices[index];
      });
    }

    final List<DropdownMenuEntry<String>> categoryList = [
      const DropdownMenuEntry<String>(
        value: "",
        label: "",
      ),
    ];

    final List<DropdownMenuEntry<String>> menuEntries = [
      DropdownMenuEntry<String>(
        value: accountViewModel.account!.username,
        label: locale.me.capitalize(),
      ),
    ];

    final List<DropdownMenuEntry<String?>> accountList = [
      const DropdownMenuEntry<String>(
        value: "",
        label: "",
      )
    ];

    for (var account in accountViewModel.accounts!) {
      accountList.add(DropdownMenuEntry<String>(
        value: account.id.toString(),
        label: account.name,
      ));
    }

    for (var category in categoryViewModel.categories) {
      categoryList.add(DropdownMenuEntry<String>(
        value: category.id.toString(),
        label: category.title,
      ));
    }

    for (var account in accountViewModel.contributorAccounts ?? []) {
      if (profileViewModel.user!.hasPermission(
          account: account,
          permissionsNeeded: ["transfert_item"],
          permissions: account.permissions)) {
        accountList.add(DropdownMenuEntry<String>(
          value: account.id.toString(),
          label: account.name,
        ));
      }
    }

    if (widget.action == "update" ||
        profileViewModel.user!.hasPermission(
          account: accountViewModel.account,
          permissionsNeeded: ["link_user_item"],
          permissions: accountViewModel.account!.permissions,
        )) {
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
        profileViewModel.user!.hasPermission(
          account: accountViewModel.account,
          permissionsNeeded: ["add_item_without_user"],
          permissions: accountViewModel.account!.permissions,
        )) {
      menuEntries.add(
        const DropdownMenuEntry<String>(
          value: "",
          label: "",
        ),
      );
    } else {
      _username = accountViewModel.account!.username;
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
          toAccount: _toAccount != "" ? _toAccount : null,
        );
      } else {
        return await accountViewModel.updateItem(
          title: titleController.text,
          description: descriptionController.text,
          valuation: valuation,
          username: _username != "" ? _username : null,
          toAccount: _toAccount != "" ? _toAccount : null,
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
                textCapitalization: TextCapitalization.sentences,
                controller: titleController,
                decoration:
                    InputDecoration(labelText: locale.title.capitalize()),
                maxLength: 15,
                validator: (value) => ValidationHelper.validateInput(
                    value, ["notEmpty", "notNull", "validTextOrDigitOnly"]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: descriptionController,
                decoration:
                    InputDecoration(labelText: locale.description.capitalize()),
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: valuationController,
                decoration:
                    InputDecoration(labelText: locale.valuation.capitalize()),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                expandedInsets: const EdgeInsets.all(50),
                label: Text(locale.category(1).capitalize()),
                initialSelection: _category,
                onSelected: (value) => setState(() {
                  _category = value!;
                }),
                dropdownMenuEntries: categoryList,
              ),
              const SizedBox(height: 16),
              DropdownMenu(
                expandedInsets: const EdgeInsets.all(50),
                label: Text("${locale.item_owner}:".capitalize()),
                initialSelection: _username,
                onSelected: (value) => setState(() {
                  _username = value!;
                }),
                dropdownMenuEntries: menuEntries,
              ),
              const SizedBox(height: 16),
              DropdownMenu(
                expandedInsets: const EdgeInsets.all(50),
                label: Text("${locale.transfert_to}:".capitalize()),
                initialSelection: _toAccount,
                onSelected: (value) => setState(() {
                  _toAccount = value!;
                }),
                dropdownMenuEntries: accountList,
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
                children: [
                  Text(locale.expense.capitalize()),
                  Text(locale.income.capitalize())
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.action == "update" &&
                      profileViewModel.user!.hasPermission(
                        ressource: widget.item,
                        account: accountViewModel.account,
                        permissionsNeeded: ["delete_item"],
                        permissions: accountViewModel.account!.permissions,
                      ))
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
                      child: Text(locale.action("delete").capitalize()),
                    ),
                  if (profileViewModel.user!.hasPermission(
                    ressource: widget.item,
                    account: accountViewModel.account,
                    permissionsNeeded: [
                      "${widget.action == "update" ? "change" : "add"}_item"
                    ],
                    permissions: accountViewModel.account!.permissions,
                  ))
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
                      child: Text(locale.action(widget.action).capitalize()),
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
