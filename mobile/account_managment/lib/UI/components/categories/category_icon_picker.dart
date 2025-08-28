import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:account_managment/config/custom_icon_pack.dart';
import 'package:account_managment/config/icon_picker_trad.dart';

class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker(
      {super.key, required this.selectedIcon, required this.onIconSelected});

  final IconPickerIcon? selectedIcon;
  final ValueChanged<IconPickerIcon?> onIconSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    Future<void> pickIcon() async {
      IconPickerIcon? icon = await showIconPicker(
        context,
        configuration: SinglePickerConfiguration(
          title: Text(locale.pick_icon.capitalize()),
          closeChild: Text(locale.close.capitalize()),
          searchHintText: locale.search.capitalize(),
          customIconPack: customIcons,
          iconPackModes: [IconPack.material, IconPack.custom],
          searchComparator: (String searchValue, IconPickerIcon icon) =>
              icon.name.toLowerCase().contains(searchValue.toLowerCase()) ||
              (traductions[icon.name] ?? icon.name)
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()),
        ),
      );
      if (icon != null) {
        onIconSelected(icon);
      }
    }

    return ElevatedButton(
      onPressed: pickIcon,
      child: Icon(selectedIcon?.data),
    );
  }
}
