import 'package:account_managment/UI/components/items/item_dropdown.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemAccountDropdown extends ItemDropdown {
  const ItemAccountDropdown({
    super.key,
    required super.onSelect,
    super.initialValue,
    super.values,
    required this.contributorAccounts,
    required this.account,
    required this.user,
  });

  final List<dynamic> contributorAccounts;
  final Account account;
  final User user;

  @override
  List<DropdownMenuEntry<String>> buildList(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    final List<DropdownMenuEntry<String>> list = [
      DropdownMenuEntry<String>(
        value: "",
        label: locale.no_transfer.capitalize(),
      ),
    ];

    for (var (account as Account) in values) {
      if (account.id != this.account.id) {
        list.add(DropdownMenuEntry<String>(
          value: account.id.toString(),
          label: account.name,
        ));
      }
    }

    for (var (account as Account) in contributorAccounts) {
      if (user.hasPermission(
          account: account,
          permissionsNeeded: ["transfert_item"],
          permissions: account.permissions)) {
        list.add(DropdownMenuEntry<String>(
          value: account.id.toString(),
          label: account.name,
        ));
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context, {String label = ""}) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return super.build(context, label: "${locale.transfert_to}:".capitalize());
  }
}
