import 'package:account_managment/UI/components/items/item_dropdown.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/account.dart';
import 'package:account_managment/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemOwnerDropdown extends ItemDropdown {
  const ItemOwnerDropdown({
    super.key,
    required super.onSelect,
    super.initialValue,
    super.values,
    required this.account,
    required this.user,
  });

  final Account account;
  final User user;

  @override
  List<DropdownMenuEntry<String>> buildList(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    final List<DropdownMenuEntry<String>> list = [
      DropdownMenuEntry<String>(
        value: user.username,
        label: locale.me.capitalize(),
      ),
    ];

    if (user.hasPermission(
      account: account,
      permissionsNeeded: ["link_user_item"],
      permissions: account.permissions,
    )) {
      list.addAll(
        account.contributor.map(
          (contributor) => DropdownMenuEntry<String>(
            value: contributor.username,
            label: contributor.username,
          ),
        ),
      );
    }

    if (user.hasPermission(
      account: account,
      permissionsNeeded: ["add_item_without_user"],
      permissions: account.permissions,
    )) {
      list.add(
        const DropdownMenuEntry<String>(
          value: "",
          label: "",
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context, {String label = ""}) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return super.build(context, label: "${locale.item_owner}:".capitalize());
  }
}
