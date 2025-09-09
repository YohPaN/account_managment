import 'package:account_managment/UI/components/items/dropdowns/item_account_dropdown.dart';
import 'package:account_managment/UI/components/items/dropdowns/item_categories_dropdown.dart';
import 'package:account_managment/UI/components/items/dropdowns/item_owner_dropdown.dart';
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
                ItemCategoriesDropdown(
                    initialValue: _category,
                    values: categoryViewModel.categories,
                    onSelect: (value) {
                      setState(() {
                        _category = value!;
                      });
                    }),
                const SizedBox(height: 16),
                ItemOwnerDropdown(
                    initialValue: _username,
                    account: accountViewModel.account!,
                    user: profileViewModel.user!,
                    values: accountViewModel.account!.contributor,
                    onSelect: (value) {
                      setState(() {
                        _username = value!;
                      });
                    }),
                const SizedBox(height: 16),
                ItemAccountDropdown(
                    initialValue: _toAccount,
                    account: accountViewModel.account!,
                    user: profileViewModel.user!,
                    contributorAccounts:
                        accountViewModel.contributorAccounts ?? [],
                    values: accountViewModel.accounts +
                        (accountViewModel.contributorAccounts ?? []),
                    onSelect: (value) {
                      setState(() {
                        _toAccount = value!;
                      });
                    }),
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
