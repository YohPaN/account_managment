import 'package:account_managment/UI/components/items/item_switch_button.dart';
import 'package:account_managment/helpers/internal_notification_helper.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/helpers/validation_helper.dart';
import 'package:account_managment/models/item.dart';
import 'package:account_managment/models/repo_reponse.dart';
import 'package:account_managment/viewModels/account_view_model.dart';
import 'package:account_managment/viewModels/category_view_model.dart';
import 'package:account_managment/viewModels/item_view_model.dart';
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
  String _username = "";
  String _toAccount = "";
  String _category = "";
  bool isIncome = false;

  @override
  void initState() {
    super.initState();
    if (widget.action == "update") {
      if (widget.item!.valuation > 0) {
        isIncome = true;
      }

      if (widget.item != null) {
        titleController.text = widget.item!.title;
        descriptionController.text = widget.item!.description ?? "";
        valuationController.text = widget.item!.valuation.abs().toString();
        _username = widget.item!.username ?? "";
        _toAccount = widget.item!.toAccount?["id"] ?? "";
        _category = widget.item!.category?.id.toString() ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AccountViewModel accountViewModel =
        Provider.of<AccountViewModel>(context, listen: false);
    final ItemViewModel itemViewModel =
        Provider.of<ItemViewModel>(context, listen: false);
    final ProfileViewModel profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    final CategoryViewModel categoryViewModel =
        Provider.of<CategoryViewModel>(context, listen: false);
    final AppLocalizations locale = AppLocalizations.of(context)!;

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

    for (var account in accountViewModel.accounts) {
      if (account.id != accountViewModel.account!.id) {
        accountList.add(DropdownMenuEntry<String>(
          value: account.id.toString(),
          label: account.name,
        ));
      }
    }

    for (var category in categoryViewModel.categories) {
      categoryList.add(DropdownMenuEntry<String>(
          value: category.id.toString(),
          label: (locale.default_category_title(category.title) != ""
                  ? locale.default_category_title(category.title)
                  : category.title)
              .capitalize()));
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
      final valuation =
          isIncome ? valuationController.text : "-${valuationController.text}";

      if (widget.action == "create") {
        return await itemViewModel.createItem(
          account: accountViewModel.account!,
          title: titleController.text,
          description: descriptionController.text,
          valuation: valuation,
          categoryId: _category != "" ? int.parse(_category) : null,
          username: _username != "" ? _username : null,
          toAccount: _toAccount != "" ? _toAccount : null,
        );
      } else {
        return await itemViewModel.updateItem(
          account: accountViewModel.account!,
          title: titleController.text,
          description: descriptionController.text,
          valuation: valuation,
          categoryId: _category != "" ? int.parse(_category) : null,
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
      child: SafeArea(
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
                  decoration: InputDecoration(
                      labelText: locale.description.capitalize()),
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
                ItemSwitchButton(
                  onSwitch: (value) {
                    setState(() {
                      isIncome = value;
                    });
                  },
                  isIncome: isIncome,
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
                              await itemViewModel.deleteItem(
                            account: accountViewModel.account!,
                            itemId: widget.item!.id,
                          );
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
      ),
    );
  }
}
