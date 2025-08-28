import 'package:account_managment/helpers/capitalize_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemSwitchButton extends StatefulWidget {
  final bool isIncome;
  final ValueChanged<bool> onSwitch;

  const ItemSwitchButton(
      {super.key, required this.isIncome, required this.onSwitch});

  @override
  State<ItemSwitchButton> createState() => _ItemSwitchButtonState();
}

class _ItemSwitchButtonState extends State<ItemSwitchButton> {
  late Map<String, Color?> _buttonStyle;
  List<bool> _selectButton = [true, false];

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

  @override
  void initState() {
    super.initState();
    _selectButton = [!widget.isIncome, widget.isIncome];
    _buttonStyle =
        !widget.isIncome ? buttonStyleChoices[0] : buttonStyleChoices[1];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    switchButton(index) {
      setState(() {
        for (int i = 0; i < _selectButton.length; i++) {
          _selectButton[i] = i == index;
        }

        _buttonStyle = buttonStyleChoices[index];
      });

      widget.onSwitch(index == 1);
    }

    return ToggleButtons(
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
    );
  }
}
