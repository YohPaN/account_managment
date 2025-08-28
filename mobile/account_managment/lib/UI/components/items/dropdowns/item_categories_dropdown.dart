import 'package:account_managment/UI/components/items/item_dropdown.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:account_managment/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemCategoriesDropdown extends ItemDropdown {
  const ItemCategoriesDropdown({
    super.key,
    required super.onSelect,
    super.initialValue,
    super.values,
  });

  @override
  List<DropdownMenuEntry<String>> buildList(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    final List<DropdownMenuEntry<String>> list = [
      DropdownMenuEntry<String>(
        value: "",
        label: locale.no_category.capitalize(),
      ),
    ];

    for (var (category as CategoryApp) in values) {
      list.add(DropdownMenuEntry<String>(
          value: category.id.toString(),
          label: (locale.default_category_title(category.title).isNotEmpty
                  ? locale.default_category_title(category.title)
                  : category.title)
              .capitalize()));
    }

    return list;
  }

  @override
  Widget build(BuildContext context, {String label = ""}) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return super.build(context, label: locale.category(1).capitalize());
  }
}
