import 'package:flutter/material.dart';
import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    Future<void> colorDialogBuilder(BuildContext context) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(locale.pick_color.capitalize()),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(locale.close.capitalize()),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: currentColor),
      onPressed: () async {
        await colorDialogBuilder(context);
      },
      child: const Icon(Icons.brush, color: Colors.white, size: 24.0),
    );
  }
}
